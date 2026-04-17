// Barcode Scanner Widget for NexaTrace System
// This file contains the barcode scanner widget used throughout the application

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class BarcodeScanner extends StatefulWidget {
  final ValueChanged<String> onScan;
  final VoidCallback? onClose;
  final String? title;
  final bool showFlash;
  final bool showSwitchCamera;
  final Color? overlayColor;
  final double overlayOpacity;
  final Duration scanDelay;
  final bool vibrateOnScan;
  final bool showScanLine;
  final bool showScanArea;
  final double scanAreaSize;
  final BorderRadius? scanAreaBorderRadius;

  const BarcodeScanner({
    super.key,
    required this.onScan,
    this.onClose,
    this.title,
    this.showFlash = true,
    this.showSwitchCamera = true,
    this.overlayColor,
    this.overlayOpacity = 0.5,
    this.scanDelay = const Duration(milliseconds: 1000),
    this.vibrateOnScan = true,
    this.showScanLine = true,
    this.showScanArea = true,
    this.scanAreaSize = 250,
    this.scanAreaBorderRadius,
  });

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  late MobileScannerController _controller;
  bool _isFlashOn = false;
  bool _isScanning = false;
  DateTime? _lastScanTime;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      torchEnabled: _isFlashOn,
      facing: CameraFacing.back,
      formats: [BarcodeFormat.all],
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
    });
    _controller.toggleTorch();
  }

  void _switchCamera() {
    _controller.switchCamera();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isScanning) return;

    if (capture.barcodes.isEmpty) return;
    final barcode = capture.barcodes.first;
    final rawValue = barcode.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    final now = DateTime.now();
    if (_lastScanTime != null &&
        now.difference(_lastScanTime!) < widget.scanDelay) {
      return;
    }

    setState(() {
      _isScanning = true;
    });

    _lastScanTime = now;

    // Vibrate on scan if enabled
    if (widget.vibrateOnScan) {
      // TODO: Implement vibration
      // HapticFeedback.vibrate();
    }

    // Call the onScan callback
    widget.onScan(rawValue);

    // Reset scanning state after delay
    Future.delayed(widget.scanDelay, () {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    });
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

          // Bottom bar
          _buildBottomBar(),

          // Scan area
          if (widget.showScanArea) _buildScanArea(),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      color: (widget.overlayColor ?? Colors.black)
          .withValues(alpha: widget.overlayOpacity),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          IconButton(
            onPressed: widget.onClose ?? () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
          ),

          // Title
          if (widget.title != null)
            Text(
              widget.title!,
              style: TextStyles.heading6.copyWith(color: Colors.white),
            ),

          // Spacer to balance the layout
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 16,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Flash button
          if (widget.showFlash)
            _buildControlButton(
              icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
              onPressed: _toggleFlash,
              label: _isFlashOn ? 'Flash On' : 'Flash Off',
            ),

          const SizedBox(width: 32),

          // Switch camera button
          if (widget.showSwitchCamera)
            _buildControlButton(
              icon: Icons.cameraswitch,
              onPressed: _switchCamera,
              label: 'Switch Camera',
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white, size: 28),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyles.caption.copyWith(color: Colors.white)),
      ],
    );
  }

  Widget _buildScanArea() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scanAreaSize = widget.scanAreaSize;

    return Positioned(
      top: (screenHeight - scanAreaSize) / 2,
      left: (screenWidth - scanAreaSize) / 2,
      child: Container(
        width: scanAreaSize,
        height: scanAreaSize,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 2),
          borderRadius:
              widget.scanAreaBorderRadius ?? BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Corner borders
            _buildCornerBorder(top: 0, left: 0, isTopLeft: true),
            _buildCornerBorder(top: 0, right: 0, isTopRight: true),
            _buildCornerBorder(bottom: 0, left: 0, isBottomLeft: true),
            _buildCornerBorder(bottom: 0, right: 0, isBottomRight: true),

            // Scan line
            if (widget.showScanLine && !_isScanning) _buildScanLine(),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerBorder({
    double? top,
    double? bottom,
    double? left,
    double? right,
    bool isTopLeft = false,
    bool isTopRight = false,
    bool isBottomLeft = false,
    bool isBottomRight = false,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.primary, width: 4),
            left: isTopLeft || isBottomLeft
                ? BorderSide(color: AppColors.primary, width: 4)
                : BorderSide.none,
            right: isTopRight || isBottomRight
                ? BorderSide(color: AppColors.primary, width: 4)
                : BorderSide.none,
            bottom: BorderSide(color: AppColors.primary, width: 4),
          ),
        ),
      ),
    );
  }

  Widget _buildScanLine() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Positioned(
          top: value * widget.scanAreaSize,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primary,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Barcode scanner with manual input option
class BarcodeScannerWithManualInput extends StatefulWidget {
  final ValueChanged<String> onScan;
  final VoidCallback? onClose;
  final String? title;
  final String manualInputHint;
  final String manualInputButtonText;

  const BarcodeScannerWithManualInput({
    super.key,
    required this.onScan,
    this.onClose,
    this.title,
    this.manualInputHint = 'Enter barcode manually',
    this.manualInputButtonText = 'Manual Input',
  });

  @override
  State<BarcodeScannerWithManualInput> createState() =>
      _BarcodeScannerWithManualInputState();
}

class _BarcodeScannerWithManualInputState
    extends State<BarcodeScannerWithManualInput> {
  bool _showManualInput = false;
  final TextEditingController _manualInputController = TextEditingController();

  void _handleManualInput() {
    final barcode = _manualInputController.text.trim();
    if (barcode.isNotEmpty) {
      widget.onScan(barcode);
      _manualInputController.clear();
      setState(() {
        _showManualInput = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Barcode scanner
          if (!_showManualInput)
            BarcodeScanner(
              onScan: widget.onScan,
              onClose: widget.onClose,
              title: widget.title,
            ),

          // Manual input overlay
          if (_showManualInput) _buildManualInputOverlay(),

          // Manual input toggle button
          if (!_showManualInput)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 100,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _showManualInput = true;
                  });
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.keyboard, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildManualInputOverlay() {
    return Container(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Manual Barcode Input',
              style: TextStyles.heading5.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _manualInputController,
              style: TextStyles.bodyLarge.copyWith(color: Colors.white),
              decoration: InputDecoration(
                hintText: widget.manualInputHint,
                hintStyle: TextStyles.bodyMedium.copyWith(
                  color: Colors.white54,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[900],
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleManualInput(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showManualInput = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _handleManualInput,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(widget.manualInputButtonText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _manualInputController.dispose();
    super.dispose();
  }
}

// Barcode scanner with multiple scan support
class MultiBarcodeScanner extends StatefulWidget {
  final ValueChanged<List<String>> onScanComplete;
  final VoidCallback? onClose;
  final String? title;
  final int maxScans;
  final String scanCompleteButtonText;

  const MultiBarcodeScanner({
    super.key,
    required this.onScanComplete,
    this.onClose,
    this.title,
    this.maxScans = 10,
    this.scanCompleteButtonText = 'Complete',
  });

  @override
  State<MultiBarcodeScanner> createState() => _MultiBarcodeScannerState();
}

class _MultiBarcodeScannerState extends State<MultiBarcodeScanner> {
  final List<String> _scannedBarcodes = [];
  bool _isScanning = false;

  void _handleBarcodeScan(String barcode) {
    if (_isScanning || _scannedBarcodes.length >= widget.maxScans) return;

    setState(() {
      _isScanning = true;
    });

    // Check if barcode already scanned
    if (!_scannedBarcodes.contains(barcode)) {
      setState(() {
        _scannedBarcodes.add(barcode);
      });
    }

    // Reset scanning state
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    });
  }

  void _completeScan() {
    widget.onScanComplete(_scannedBarcodes);
  }

  void _clearScans() {
    setState(() {
      _scannedBarcodes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Barcode scanner
          BarcodeScanner(
            onScan: _handleBarcodeScan,
            onClose: widget.onClose,
            title: widget.title,
            scanDelay: const Duration(milliseconds: 500),
          ),

          // Scanned items overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 16,
            right: 16,
            child: _buildScannedItemsOverlay(),
          ),

          // Complete button
          if (_scannedBarcodes.isNotEmpty)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: _completeScan,
                backgroundColor: AppColors.success,
                child: const Icon(Icons.check, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScannedItemsOverlay() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Scanned Items (${_scannedBarcodes.length}/${widget.maxScans})',
                style: TextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_scannedBarcodes.isNotEmpty)
                IconButton(
                  onPressed: _clearScans,
                  icon: const Icon(
                    Icons.clear_all,
                    color: Colors.white,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_scannedBarcodes.isEmpty)
            Text(
              'No items scanned yet',
              style: TextStyles.caption.copyWith(color: Colors.white54),
            )
          else
            Column(
              children: _scannedBarcodes
                  .take(3)
                  .map((barcode) => _buildScannedItem(barcode))
                  .toList(),
            ),
          if (_scannedBarcodes.length > 3)
            Text(
              '+ ${_scannedBarcodes.length - 3} more',
              style: TextStyles.caption.copyWith(color: Colors.white54),
            ),
        ],
      ),
    );
  }

  Widget _buildScannedItem(String barcode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              barcode,
              style: TextStyles.bodySmall.copyWith(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
