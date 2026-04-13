// QR Scanner Widget for NexaTrace System
// This file contains the QR scanner widget used throughout the application

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class QRScannerWidget extends StatefulWidget {
  final Function(String) onScan;
  final Function()? onClose;
  final String? title;
  final String? hintText;
  final bool showFlashToggle;
  final bool showCameraToggle;
  final bool showGalleryButton;
  final bool showManualEntry;
  final Function()? onManualEntry;
  final Color? overlayColor;
  final double overlayOpacity;
  final BorderRadius? overlayBorderRadius;
  final Duration scanDelay;

  const QRScannerWidget({
    super.key,
    required this.onScan,
    this.onClose,
    this.title,
    this.hintText,
    this.showFlashToggle = true,
    this.showCameraToggle = true,
    this.showGalleryButton = true,
    this.showManualEntry = true,
    this.onManualEntry,
    this.overlayColor,
    this.overlayOpacity = 0.5,
    this.overlayBorderRadius,
    this.scanDelay = const Duration(milliseconds: 1000),
  });

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  late MobileScannerController _controller;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  bool _isScanning = true;
  DateTime? _lastScanTime;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
      formats: [BarcodeFormat.qrCode],
      returnImage: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
      _controller.toggleTorch();
    });
  }

  void _toggleCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _controller.switchCamera();
    });
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (!_isScanning) return;

    if (capture.barcodes.isEmpty) return;
    final barcode = capture.barcodes.first;

    final now = DateTime.now();
    if (_lastScanTime != null &&
        now.difference(_lastScanTime!) < widget.scanDelay) {
      return;
    }

    _lastScanTime = now;
    final code = barcode.rawValue;

    if (code != null && code.isNotEmpty) {
      setState(() {
        _isScanning = false;
      });

      widget.onScan(code);

      // Re-enable scanning after a delay
      Future.delayed(widget.scanDelay, () {
        if (mounted) {
          setState(() {
            _isScanning = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(controller: _controller, onDetect: _handleBarcode),

          // Overlay
          _buildOverlay(),

          // Top bar
          _buildTopBar(),

          // Bottom controls
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.8,
          colors: [
            Colors.transparent,
            (widget.overlayColor ?? Colors.black)
                .withValues(alpha: widget.overlayOpacity),
          ],
          stops: const [0.3, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary, width: 2),
            borderRadius:
                widget.overlayBorderRadius ?? BorderRadius.circular(12),
          ),
          child: CustomPaint(painter: _ScannerOverlayPainter()),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Close button
            IconButton(
              onPressed: widget.onClose ?? () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                padding: const EdgeInsets.all(8),
              ),
            ),

            // Title
            if (widget.title != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.title!,
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // Spacer
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Hint text
              if (widget.hintText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    widget.hintText!,
                    style: TextStyles.bodyMedium.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Flash toggle
                  if (widget.showFlashToggle)
                    _buildControlButton(
                      icon: _isFlashOn ? Icons.flash_off : Icons.flash_on,
                      label: _isFlashOn ? 'Flash Off' : 'Flash On',
                      onPressed: _toggleFlash,
                    ),

                  // Camera toggle
                  if (widget.showCameraToggle)
                    _buildControlButton(
                      icon: _isFrontCamera
                          ? Icons.camera_rear
                          : Icons.camera_front,
                      label: _isFrontCamera ? 'Rear Camera' : 'Front Camera',
                      onPressed: _toggleCamera,
                    ),

                  // Gallery button
                  if (widget.showGalleryButton)
                    _buildControlButton(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onPressed: () {
                        // TODO: Implement gallery picker
                      },
                    ),

                  // Manual entry
                  if (widget.showManualEntry)
                    _buildControlButton(
                      icon: Icons.keyboard,
                      label: 'Manual Entry',
                      onPressed: widget.onManualEntry,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white, size: 28),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black54,
            padding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyles.caption.copyWith(color: Colors.white)),
      ],
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw corners
    final cornerLength = 20.0;
    final cornerWidth = 4.0;

    // Top left corner
    canvas.drawLine(
      Offset(0, cornerLength),
      Offset(0, 0),
      paint..strokeWidth = cornerWidth,
    );
    canvas.drawLine(
      Offset(0, 0),
      Offset(cornerLength, 0),
      paint..strokeWidth = cornerWidth,
    );

    // Top right corner
    canvas.drawLine(
      Offset(size.width - cornerLength, 0),
      Offset(size.width, 0),
      paint..strokeWidth = cornerWidth,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint..strokeWidth = cornerWidth,
    );

    // Bottom right corner
    canvas.drawLine(
      Offset(size.width, size.height - cornerLength),
      Offset(size.width, size.height),
      paint..strokeWidth = cornerWidth,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - cornerLength, size.height),
      paint..strokeWidth = cornerWidth,
    );

    // Bottom left corner
    canvas.drawLine(
      Offset(cornerLength, size.height),
      Offset(0, size.height),
      paint..strokeWidth = cornerWidth,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - cornerLength),
      paint..strokeWidth = cornerWidth,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Compact QR scanner for inline use
class CompactQRScanner extends StatefulWidget {
  final Function(String) onScan;
  final double height;
  final double width;
  final bool showControls;
  final BorderRadius? borderRadius;

  const CompactQRScanner({
    super.key,
    required this.onScan,
    this.height = 200,
    this.width = 200,
    this.showControls = false,
    this.borderRadius,
  });

  @override
  State<CompactQRScanner> createState() => _CompactQRScannerState();
}

class _CompactQRScannerState extends State<CompactQRScanner> {
  late MobileScannerController _controller;
  bool _isScanning = true;
  DateTime? _lastScanTime;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
      formats: [BarcodeFormat.qrCode],
      returnImage: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (!_isScanning) return;

    if (capture.barcodes.isEmpty) return;
    final barcode = capture.barcodes.first;

    final now = DateTime.now();
    if (_lastScanTime != null &&
        now.difference(_lastScanTime!) < Duration(milliseconds: 1000)) {
      return;
    }

    _lastScanTime = now;
    final code = barcode.rawValue;

    if (code != null && code.isNotEmpty) {
      setState(() {
        _isScanning = false;
      });

      widget.onScan(code);

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _isScanning = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray300, width: 1),
      ),
      child: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
            fit: BoxFit.cover,
          ),
          if (widget.showControls)
            Positioned(
              bottom: 8,
              right: 8,
              child: IconButton(
                onPressed: () {
                  // TODO: Show full scanner
                },
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }
}

// QR scanner with result preview
class QRScannerWithPreview extends StatefulWidget {
  final Function(String) onScan;
  final Widget Function(String)? previewBuilder;
  final bool showPreview;
  final Duration previewDuration;

  const QRScannerWithPreview({
    super.key,
    required this.onScan,
    this.previewBuilder,
    this.showPreview = true,
    this.previewDuration = const Duration(seconds: 3),
  });

  @override
  State<QRScannerWithPreview> createState() => _QRScannerWithPreviewState();
}

class _QRScannerWithPreviewState extends State<QRScannerWithPreview> {
  String? _lastScannedCode;
  bool _showPreview = false;

  void _handleScan(String code) {
    setState(() {
      _lastScannedCode = code;
      _showPreview = true;
    });

    widget.onScan(code);

    if (widget.showPreview) {
      Future.delayed(widget.previewDuration, () {
        if (mounted) {
          setState(() {
            _showPreview = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        QRScannerWidget(
          onScan: _handleScan,
          title: 'Scan QR Code',
          hintText: 'Position QR code within the frame',
        ),
        if (_showPreview && _lastScannedCode != null)
          Positioned(
            top: 100,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: widget.previewBuilder != null
                  ? widget.previewBuilder!(_lastScannedCode!)
                  : Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Scanned Successfully',
                          style: TextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _lastScannedCode!,
                          style: TextStyles.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
            ),
          ),
      ],
    );
  }
}
