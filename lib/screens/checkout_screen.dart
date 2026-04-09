import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/theme.dart';
import '../utils/price_formatter.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../models/order.dart';
import '../models/coupon.dart';
import '../models/saved_address.dart';
import '../services/coupon_service.dart';
import '../services/address_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _couponController = TextEditingController();
  bool _isPlacing = false;

  // Payment method: 'cash' or 'aba_khqr'
  String _paymentMethod = 'cash';

  // Coupon state
  CouponResult? _appliedCoupon;
  bool _validatingCoupon = false;
  String? _couponError;

  // Saved addresses state
  List<SavedAddress> _savedAddresses = [];
  SavedAddress? _selectedAddress;
  bool _loadingAddresses = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        _streetController.text = user.address.street;
        _cityController.text = user.address.city;
        _countryController.text = user.address.country;
        _phoneController.text = user.phone;
      }
      _loadSavedAddresses();
    });
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedAddresses() async {
    try {
      final addresses = await AddressService.getAddresses();
      if (!mounted) return;
      setState(() {
        _savedAddresses = addresses;
        _loadingAddresses = false;
        // Auto-select default if available
        final defaultAddr = addresses.where((a) => a.isDefault).firstOrNull;
        if (defaultAddr != null) {
          _applySavedAddress(defaultAddr);
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingAddresses = false);
    }
  }

  void _applySavedAddress(SavedAddress address) {
    setState(() {
      _selectedAddress = address;
      _streetController.text = address.street;
      _cityController.text = address.city;
      _countryController.text = address.country;
      if (address.phone.isNotEmpty) {
        _phoneController.text = address.phone;
      }
    });
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    final cart = context.read<CartProvider>();
    setState(() {
      _validatingCoupon = true;
      _couponError = null;
    });

    try {
      final result = await CouponService.validateCoupon(
        code: code,
        cartTotal: cart.totalPrice,
      );
      if (!mounted) return;
      setState(() {
        _appliedCoupon = result;
        _validatingCoupon = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _couponError = e.toString().replaceFirst('Exception: ', '');
        _validatingCoupon = false;
      });
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _couponController.clear();
      _couponError = null;
    });
  }

  double get _discount => _appliedCoupon?.discount ?? 0;

  Future<void> _showAddressPicker() async {
    final selected = await showModalBottomSheet<SavedAddress>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _buildAddressSheet(ctx),
    );
    if (selected != null) _applySavedAddress(selected);
  }

  Widget _buildAddressSheet(BuildContext ctx) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saved Addresses',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            if (_savedAddresses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No saved addresses yet',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ..._savedAddresses.map(
              (addr) => InkWell(
                onTap: () => Navigator.pop(ctx, addr),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedAddress?.id == addr.id
                          ? AppTheme.primary
                          : AppTheme.divider,
                      width: _selectedAddress?.id == addr.id ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  addr.label,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (addr.isDefault) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'DEFAULT',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${addr.street}, ${addr.city}, ${addr.country}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _showNewAddressDialog();
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Save Current as New Address'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showNewAddressDialog() async {
    final labelController = TextEditingController(text: 'Home');
    bool isDefault = false;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Save Address'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: 'Label (e.g. Home, Office)',
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Set as default'),
                value: isDefault,
                onChanged: (v) =>
                    setDialogState(() => isDefault = v ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (shouldSave != true) return;
    if (_streetController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _countryController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all address fields')),
      );
      return;
    }

    try {
      final newAddr = await AddressService.createAddress(
        SavedAddress(
          id: '',
          label: labelController.text.trim(),
          street: _streetController.text.trim(),
          city: _cityController.text.trim(),
          country: _countryController.text.trim(),
          phone: _phoneController.text.trim(),
          isDefault: isDefault,
        ),
      );
      if (!mounted) return;
      setState(() {
        if (isDefault) {
          _savedAddresses = _savedAddresses
              .map(
                (a) => SavedAddress(
                  id: a.id,
                  label: a.label,
                  street: a.street,
                  city: a.city,
                  country: a.country,
                  phone: a.phone,
                  isDefault: false,
                ),
              )
              .toList();
        }
        _savedAddresses.add(newAddr);
        _selectedAddress = newAddr;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address saved'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save address'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPlacing = true);

    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    final items = cart.items
        .map(
          (item) => OrderItem(
            productId: item.product.id,
            name: item.product.name,
            price: item.product.price,
            quantity: item.quantity,
            size: item.size,
            color: item.color,
          ),
        )
        .toList();

    final shippingAddress = ShippingAddress(
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      country: _countryController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    final finalTotal = (cart.totalPrice - _discount).clamp(0, double.infinity).toDouble();

    final order = await orderProvider.placeOrder(
      items: items,
      totalPrice: finalTotal,
      shippingAddress: shippingAddress,
    );

    if (!mounted) return;
    setState(() => _isPlacing = false);

    if (order != null) {
      final totalAmount = finalTotal; // capture before clearing
      if (_paymentMethod == 'aba_khqr') {
        // Navigate to the ABA KHQR payment screen
        cart.clearCart();
        Navigator.pushReplacementNamed(
          context,
          '/payment',
          arguments: {'orderId': order.id, 'amount': totalAmount},
        );
      } else {
        // Cash on delivery — show success immediately
        cart.clearCart();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.success,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Order Placed!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your order has been placed successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/home', (route) => false);
                },
                child: const Text('Continue Shopping'),
              ),
            ],
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.error ?? 'Failed to place order'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Order summary ──────────────────────────────
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ...cart.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      // Product Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: item.product.images.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: item.product.images[0],
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 40,
                                height: 40,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image, size: 20, color: Colors.grey),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${item.product.name} x${item.quantity}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatPrice(item.totalPrice),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 24),
              // Subtotal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    formatPrice(cart.totalPrice),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              if (_appliedCoupon != null) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Discount (${_appliedCoupon!.code})',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.success,
                      ),
                    ),
                    Text(
                      '- ${formatPrice(_discount)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.success,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    formatPrice(
                      (cart.totalPrice - _discount)
                          .clamp(0, double.infinity)
                          .toDouble(),
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Coupon code ────────────────────────────────
              const Text(
                'Coupon Code',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildCouponInput(),
              const SizedBox(height: 28),

              // ── Payment method ─────────────────────────────
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildPaymentOption(
                value: 'cash',
                icon: Icons.money,
                label: 'Cash on Delivery',
              ),
              const SizedBox(height: 8),
              _buildPaymentOption(
                value: 'aba_khqr',
                icon: Icons.qr_code_2,
                label: 'ABA KHQR',
                subtitle: 'Pay via KHQR QR code',
              ),
              const SizedBox(height: 32),

              // ── Shipping address ───────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Shipping Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _loadingAddresses ? null : _showAddressPicker,
                    icon: const Icon(Icons.bookmark_outline, size: 18),
                    label: Text(
                      _savedAddresses.isEmpty ? 'Save' : 'Saved',
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ],
              ),
              if (_selectedAddress != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Using: ${_selectedAddress!.label}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              CustomTextField(
                hint: 'Street Address',
                controller: _streetController,
                prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                hint: 'City',
                controller: _cityController,
                prefixIcon: const Icon(Icons.location_city_outlined, size: 20),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                hint: 'Country',
                controller: _countryController,
                prefixIcon: const Icon(Icons.flag_outlined, size: 20),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                hint: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: _paymentMethod == 'aba_khqr'
                    ? 'Place Order & Pay'
                    : 'Place Order',
                onPressed: _placeOrder,
                isLoading: _isPlacing,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCouponInput() {
    if (_appliedCoupon != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.success, width: 1.5),
          color: AppTheme.success.withValues(alpha: 0.06),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.success,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _appliedCoupon!.code,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.success,
                    ),
                  ),
                  Text(
                    '${_appliedCoupon!.discountPercent}% off applied',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _removeCoupon,
              icon: const Icon(Icons.close, size: 18),
              tooltip: 'Remove',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                hint: 'Enter coupon code',
                controller: _couponController,
                prefixIcon: const Icon(
                  Icons.local_offer_outlined,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _validatingCoupon ? null : _applyCoupon,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 52),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: _validatingCoupon
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Apply'),
              ),
            ),
          ],
        ),
        if (_couponError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              _couponError!,
              style: const TextStyle(fontSize: 12, color: AppTheme.error),
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required IconData icon,
    required String label,
    String? subtitle,
  }) {
    final isSelected = _paymentMethod == value;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.divider,
            width: isSelected ? 1.5 : 1,
          ),
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.04)
              : AppTheme.surface,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _paymentMethod,
              onChanged: (v) => setState(() => _paymentMethod = v!),
              activeColor: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
