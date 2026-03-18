import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../config/theme.dart';
import '../utils/price_formatter.dart';
import '../services/payment_service.dart';

/// Displays an ABA KHQR QR code and polls for payment confirmation.
///
/// Expects route arguments:
/// ```dart
/// {'orderId': String, 'amount': double}
/// ```
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = true;
  String? _error;
  String? _qrString;
  String? _tranId;
  Timer? _pollTimer;
  bool _isPaid = false;
  double _amount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_qrString == null && _error == null) {
      _generateQr();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _generateQr() async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final orderId = args['orderId'] as String;
    final amount = args['amount'] as double;
    _amount = amount;

    try {
      final result = await PaymentService.generateQr(
        orderId: orderId,
        amount: amount,
      );
      if (!mounted) return;
      setState(() {
        _qrString = result['qr_string'] as String?;
        _tranId = result['tran_id'] as String?;
        _isLoading = false;
      });
      _startPolling();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_tranId == null || _isPaid) return;
      try {
        final result = await PaymentService.checkStatus(_tranId!);
        // Backend returns { is_paid: true/false, payment_status: '...' }
        final isPaid = result['is_paid'] == true;
        if (isPaid && mounted) {
          _pollTimer?.cancel();
          setState(() => _isPaid = true);
          _navigateToSuccess();
        }
      } catch (_) {
        // Silently retry on next poll
      }
    });
  }

  void _navigateToSuccess() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const _PaymentSuccessScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ABA KHQR Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating QR code...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to generate QR code',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _generateQr();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.divider.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.qr_code_2, size: 32, color: AppTheme.accent),
                const SizedBox(height: 8),
                const Text(
                  'Scan to Pay',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Open your ABA Mobile or any KHQR-supported app',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 24),

                // QR Code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: QrImageView(
                    data: _qrString!,
                    version: QrVersions.auto,
                    size: 240,
                    gapless: true,
                    errorStateBuilder: (ctx, err) =>
                        const Center(child: Text('Error rendering QR')),
                  ),
                ),

                const SizedBox(height: 16),

                // Transaction ID
                Text(
                  'Transaction: ${_tranId ?? 'N/A'}',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Total Amount ────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.accent.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  formatPrice(_amount),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Polling status indicator
          if (!_isPaid) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Waiting for payment...',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Cancel button
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Cancel Payment'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Full-screen Payment Success Screen with animated checkmark
// ─────────────────────────────────────────────────────────────────────

class _PaymentSuccessScreen extends StatefulWidget {
  const _PaymentSuccessScreen();

  @override
  State<_PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<_PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _circleController;
  late final AnimationController _checkController;
  late final AnimationController _contentController;

  late final Animation<double> _circleScale;
  late final Animation<double> _checkProgress;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    // 1 — Green circle pops in
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _circleScale = CurvedAnimation(
      parent: _circleController,
      curve: Curves.elasticOut,
    );

    // 2 — Checkmark draws
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkProgress = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeInOut,
    );

    // 3 — Text + button fades in
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentOpacity = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeIn,
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeOutCubic,
          ),
        );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _circleController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _checkController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _contentController.forward();
  }

  @override
  void dispose() {
    _circleController.dispose();
    _checkController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E7D32), Color(0xFF388E3C), Color(0xFF43A047)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              Column(
                children: [
                  const Spacer(flex: 2),

                  // Animated circle + checkmark
                  ScaleTransition(
                    scale: _circleScale,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: AnimatedBuilder(
                        animation: _checkProgress,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: _CheckPainter(_checkProgress.value),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Text content
                  SlideTransition(
                    position: _contentSlide,
                    child: FadeTransition(
                      opacity: _contentOpacity,
                      child: Column(
                        children: [
                          const Text(
                            'Payment Successful!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your payment has been confirmed.\nThank you for your order!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Continue Shopping button
                  FadeTransition(
                    opacity: _contentOpacity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/home',
                                  (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF2E7D32),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text('Continue Shopping'),
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Custom painters
// ─────────────────────────────────────────────────────────────────────

/// Draws an animated checkmark inside the circle.
class _CheckPainter extends CustomPainter {
  final double progress;
  _CheckPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // The check consists of two line segments:
    // Point 1 → Point 2 (short downward stroke)
    // Point 2 → Point 3 (long upward stroke)
    final p1 = Offset(cx - 20, cy);
    final p2 = Offset(cx - 5, cy + 16);
    final p3 = Offset(cx + 22, cy - 14);

    final path = Path();
    path.moveTo(p1.dx, p1.dy);

    if (progress <= 0.4) {
      // First segment (short leg)
      final t = progress / 0.4;
      final x = p1.dx + (p2.dx - p1.dx) * t;
      final y = p1.dy + (p2.dy - p1.dy) * t;
      path.lineTo(x, y);
    } else {
      // Complete first segment + partial second
      path.lineTo(p2.dx, p2.dy);
      final t = (progress - 0.4) / 0.6;
      final x = p2.dx + (p3.dx - p2.dx) * t;
      final y = p2.dy + (p3.dy - p2.dy) * t;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}
