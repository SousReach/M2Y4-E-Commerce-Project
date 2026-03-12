const express = require('express');
const crypto = require('crypto');
const axios = require('axios');
const Order = require('../models/Order');

const router = express.Router();

// ── Helpers ──────────────────────────────────────────────────────────

/** ABA req_time must be yyyyMMddHHmmss in UTC */
function paywayReqTime() {
  const d = new Date();
  const Y = d.getUTCFullYear().toString();
  const M = (d.getUTCMonth() + 1).toString().padStart(2, '0');
  const D = d.getUTCDate().toString().padStart(2, '0');
  const h = d.getUTCHours().toString().padStart(2, '0');
  const m = d.getUTCMinutes().toString().padStart(2, '0');
  const s = d.getUTCSeconds().toString().padStart(2, '0');
  return `${Y}${M}${D}${h}${m}${s}`;
}

/** HMAC-SHA512 → base64.  Pass an array of strings; they are joined then hashed. */
function createHash(values) {
  const message = values.join('');
  return crypto
    .createHmac('sha512', process.env.ABA_API_KEY)
    .update(message)
    .digest('base64');
}

/** Remove undefined / null / empty-string values from an object (ABA SDK filterParams) */
function filterParams(params) {
  const out = {};
  for (const [key, value] of Object.entries(params)) {
    if (value !== undefined && value !== null && value !== '') {
      out[key] = value;
    }
  }
  return out;
}

// ── POST /generate-qr ───────────────────────────────────────────────
router.post('/generate-qr', async (req, res) => {
  try {
    const {
      amount,
      orderId,
      currency = 'USD',
      firstname = 'Customer',
      lastname = 'User',
      email = 'test@example.com',
      phone = '093630466',
    } = req.body;

    if (!amount || Number(amount) <= 0) {
      return res.status(400).json({ message: 'amount must be > 0' });
    }

    // Format amount: 2 decimals for USD, integer for KHR
    const fixedAmount =
      currency === 'KHR'
        ? Math.round(Number(amount)).toString()
        : parseFloat(amount).toFixed(2);

    const req_time = paywayReqTime();
    const tran_id = req_time + Math.floor(Math.random() * 10000);

    // QR-specific fields
    const payment_option = 'abapay_khqr';
    const lifetime = '900';              // 15 minutes
    const qr_image_template = 'template3_color';

    // Optional fields we're not using
    const items = '';
    const callback_url = '';
    const return_deeplink = '';
    const custom_fields = '';
    const return_params = '';
    const purchase_type = '';
    const payout = '';

    // ── Hash: exact field order from official ABA SDK generateQR ──
    const hash = createHash([
      req_time,
      process.env.ABA_MERCHANT_ID,
      tran_id,
      fixedAmount,
      items,            // items (empty)
      firstname,
      lastname,
      email,
      phone,
      purchase_type,    // purchase_type (empty)
      payment_option,
      callback_url,     // callback_url (empty)
      return_deeplink,  // return_deeplink (empty)
      currency,
      custom_fields,    // custom_fields (empty)
      return_params,    // return_params (empty)
      payout,           // payout (empty)
      lifetime,
      qr_image_template,
    ]);

    // Link ABA tran_id to the order in the DB
    if (orderId) {
      await Order.findByIdAndUpdate(orderId, {
        abaTranId: tran_id,
        paymentMethod: 'aba_khqr',
      });
    }

    // ── Build JSON body (filterParams removes empty values) ──
    const body = filterParams({
      hash,
      req_time,
      merchant_id: process.env.ABA_MERCHANT_ID,
      tran_id,
      amount: fixedAmount,
      currency,
      payment_option,
      lifetime: Number(lifetime),
      qr_image_template,
      first_name: firstname,
      last_name: lastname,
      email,
      phone,
      purchase_type,
      items: items || undefined,
      callback_url: callback_url || undefined,
      return_deeplink: return_deeplink || undefined,
      custom_fields: custom_fields || undefined,
      return_params,
      payout: payout || undefined,
    });

    // Use the generate-qr endpoint (not /purchase)
    const API_BASE = process.env.ABA_PAYWAY_API_URL.replace(
      '/payments/purchase',
      '/payments/generate-qr',
    );

    console.log('Sending to:', API_BASE);
    console.log('Body:', JSON.stringify(body, null, 2));

    const response = await axios.post(API_BASE, JSON.stringify(body), {
      headers: { 'Content-Type': 'application/json' },
    });

    console.log('✅ ABA RAW RESPONSE:', JSON.stringify(response.data, null, 2));

    const code = response.data?.status?.code;
    if (code === '00' || code === 0 || code === '0') {
      // Try all known QR field names
      const qr =
        response.data.qr_image ??
        response.data.qr_string ??
        response.data.qrString ??
        response.data.qr ??
        response.data.data?.qr_image ??
        response.data.data?.qr_string ??
        response.data.data?.qrString ??
        response.data.data?.qr ??
        response.data.abapay_deeplink ??
        response.data.khqr;

      if (!qr) {
        console.error('❌ PayWay returned success but no qr field. Full payload:', response.data);
        return res.status(502).json({
          message: 'PayWay returned success but no QR field found',
          tran_id,
          payload: response.data,
        });
      }

      return res.json({ qr_string: qr, tran_id });
    }

    return res.status(400).json({
      message: 'PayWay returned an error',
      details: response.data,
    });
  } catch (error) {
    console.error('ABA generate-qr error:', error.response?.data ?? error.message);
    return res.status(500).json({ message: 'Internal Server Error' });
  }
});

// ── POST /check-status ──────────────────────────────────────────────
router.post('/check-status', async (req, res) => {
  try {
    const { tran_id } = req.body;

    if (!tran_id) {
      return res.status(400).json({ message: 'tran_id is required' });
    }

    const req_time = paywayReqTime();

    // Hash for check-transaction: req_time + merchant_id + tran_id
    const hash = createHash([req_time, process.env.ABA_MERCHANT_ID, tran_id]);

    const body = filterParams({
      hash,
      tran_id,
      req_time,
      merchant_id: process.env.ABA_MERCHANT_ID,
    });

    // Use check-transaction-2 endpoint (from SDK)
    const CHECK_URL = process.env.ABA_PAYWAY_API_URL.replace(
      '/payments/purchase',
      '/payments/check-transaction-2',
    );

    const response = await axios.post(CHECK_URL, JSON.stringify(body), {
      headers: { 'Content-Type': 'application/json' },
    });

    console.log('ABA check-status response:', JSON.stringify(response.data, null, 2));

    // The API status.code '0' just means the API call succeeded.
    // The actual payment status is in data.payment_status:
    //   - "Approved" = payment completed
    //   - "Pending"  = waiting for payment
    //   - "Declined" = payment declined/cancelled
    const apiCode = response.data?.status?.code;
    const paymentStatus = response.data?.data?.payment_status
      ?? response.data?.payment_status
      ?? response.data?.data?.status;

    const isPaid = paymentStatus === 'Approved'
      || paymentStatus === 'approved'
      || paymentStatus === 'APPROVED';

    if (isPaid) {
      await Order.findOneAndUpdate(
        { abaTranId: tran_id },
        { status: 'paid' },
      );
    }

    // Return a simplified response for Flutter to check
    return res.json({
      status: response.data?.status,
      payment_status: paymentStatus ?? 'Pending',
      is_paid: isPaid,
      data: response.data?.data,
    });
  } catch (error) {
    console.error('ABA check-status error:', error.response?.data ?? error.message);
    return res.status(500).json({ message: 'Status check failed' });
  }
});

module.exports = router;
