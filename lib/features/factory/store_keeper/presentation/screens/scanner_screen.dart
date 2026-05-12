import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nexatrace_system/features/factory/store_keeper/presentation/bloc/store_keeper_bloc.dart';
import 'package:nexatrace_system/features/factory/store_keeper/presentation/widgets/torch_button.dart';
import 'package:nexatrace_system/features/factory/store_keeper/presentation/widgets/scanner_overlay.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/theme/text_styles.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';

class ScannerScreen extends StatefulWidget {
  final bool returnResult;
  const ScannerScreen({super.key, this.returnResult = false});
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with WidgetsBindingObserver {
  late final MobileScannerController _cameraController;
  final _manualEntryController = TextEditingController();
  bool _isTorchOn = false;
  bool _isBatchMode = false;
  bool _showManualEntry = false;
  final List<String> _batchCodes = [];
  String? _lastScannedCode;
  String? _lastScannedType;
  DateTime? _lastScanTime;
  bool _isProcessing = false;
  int _totalScanAttempts = 0;
  int _successfulScans = 0;
  Timer? _torchAutoOffTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraController = MobileScannerController(
      formats: const [BarcodeFormat.all],
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      returnImage: false,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _torchAutoOffTimer?.cancel();
    _cameraController.dispose();
    _manualEntryController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        _cameraController.stop();
      case AppLifecycleState.resumed:
        _cameraController.start();
      default:
    }
  }

  void _handleBarcode(BarcodeCapture capture) {
    final now = DateTime.now();
    if (_lastScanTime != null && now.difference(_lastScanTime!) < const Duration(milliseconds: 1500)) return;
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final barcode = barcodes.first;
    final rawValue = barcode.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;
    final code = rawValue.trim();
    _totalScanAttempts++;
    if (_isTorchOn) _toggleTorch(automatic: true);
    _processScan(code);
    _successfulScans++;
  }

  void _processScan(String code) {
    setState(() {
      _isProcessing = true;
      _lastScannedCode = code;
      _lastScannedType = _inferCodeType(code);
      _lastScanTime = DateTime.now();
      if (_isBatchMode) _batchCodes.add(code);
    });
    context.read<StoreKeeperBloc>().add(ScanCode(code: code, codeType: _lastScannedType));
    if (widget.returnResult) {
      Future.delayed(const Duration(milliseconds: 300), () { if (mounted) context.pop(code); });
      return;
    }
    Future.delayed(const Duration(milliseconds: 800), () { if (mounted) setState(() => _isProcessing = false); });
  }

  void _toggleTorch({bool automatic = false}) {
    _cameraController.toggleTorch();
    setState(() => _isTorchOn = !_isTorchOn);
    _torchAutoOffTimer?.cancel();
    if (!automatic && _isTorchOn) {
      _torchAutoOffTimer = Timer(const Duration(seconds: 10), () {
        if (_isTorchOn && mounted) { _cameraController.toggleTorch(); setState(() => _isTorchOn = false); }
      });
    }
  }

  void _submitManualEntry() {
    final code = _manualEntryController.text.trim();
    if (code.isEmpty) return;
    _totalScanAttempts++;
    _processScan(code);
    _manualEntryController.clear();
    setState(() => _showManualEntry = false);
    _successfulScans++;
  }

  String _inferCodeType(String code) {
    final upper = code.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (upper.startsWith('BND') || upper.startsWith('BUN')) return 'bundle';
    if (upper.startsWith('CTN') || upper.startsWith('CAR')) return 'carton';
    if (upper.startsWith('PKT') || upper.startsWith('PAC')) return 'packet';
    if (upper.startsWith('UNT') || upper.startsWith('UNI')) return 'unit';
    if (RegExp(r'^[A-Z]{2,3}\d{3,}$').hasMatch(upper)) return 'unit';
    return 'unit';
  }

  double get _successRate => _totalScanAttempts == 0 ? 1.0 : _successfulScans / _totalScanAttempts;

  void _showQualityCheckDialog() {
    final rate = _successRate;
    final needsAttention = rate < 0.95;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Scanner Quality Check'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(needsAttention ? Icons.warning_amber : Icons.check_circle, size: 48.w, color: needsAttention ? AppColors.warning : AppColors.success),
          Gap(12.h),
          Text('Success Rate: ${(rate * 100).toStringAsFixed(1)}%', style: TextStyles.heading5),
          Gap(8.h),
          Text('$_successfulScans / $_totalScanAttempts scans', style: TextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          Gap(12.h),
          if (needsAttention) Container(padding: EdgeInsets.all(12.w), decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)), child: Text('Below 95%. Check phone camera lens.', style: TextStyles.caption.copyWith(color: AppColors.warning), textAlign: TextAlign.center)),
        ]),
        actions: [
          if (needsAttention) TextButton(onPressed: () { Navigator.of(ctx).pop(); _resetMetrics(); }, child: const Text('Reset & Retry')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _resetMetrics() { setState(() { _totalScanAttempts = 0; _successfulScans = 0; }); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_isBatchMode ? 'Batch Scanner' : 'Scanner'),
        backgroundColor: Colors.black, foregroundColor: Colors.white, elevation: 0,
        actions: [
          if (_totalScanAttempts > 0) IconButton(icon: Icon(_successRate >= 0.95 ? Icons.check_circle_outline : Icons.warning_amber, color: _successRate >= 0.95 ? AppColors.success : AppColors.warning), tooltip: 'Quality: ${(_successRate * 100).toStringAsFixed(0)}%', onPressed: _showQualityCheckDialog),
          IconButton(icon: Icon(_isBatchMode ? Icons.filter_none : Icons.filter_none_outlined, color: _isBatchMode ? AppColors.secondary : Colors.white), tooltip: _isBatchMode ? 'Batch ON' : 'Batch OFF', onPressed: () { setState(() { _isBatchMode = !_isBatchMode; if (!_isBatchMode) _batchCodes.clear(); }); }),
          IconButton(icon: Icon(Icons.keyboard, color: _showManualEntry ? AppColors.accent : Colors.white), tooltip: 'Manual Entry', onPressed: () => setState(() => _showManualEntry = !_showManualEntry)),
        ],
      ),
      body: Stack(fit: StackFit.expand, children: [
        MobileScanner(controller: _cameraController, onDetect: _handleBarcode, errorBuilder: (context, error, child) => _buildError(error.toString())),
        const ScannerOverlay(),
        if (_lastScannedCode != null) Positioned(top: 8.h, left: 16.w, right: 16.w, child: SafeArea(child: Container(padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h), decoration: BoxDecoration(color: Colors.black.withOpacity(0.75), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.success.withOpacity(0.5))), child: Row(children: [const Icon(Icons.check_circle, color: AppColors.success, size: 20), Gap(8.w), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(_lastScannedCode!, style: TextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis), Text('Type: ${_lastScannedType?.toUpperCase() ?? 'unknown'}', style: TextStyles.caption.copyWith(color: Colors.white70))])), if (_isProcessing) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))]))))),
        if (_isBatchMode && _batchCodes.isNotEmpty) Positioned(top: 72.h, right: 16.w, child: SafeArea(child: Container(padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h), decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(20.r)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.inventory, color: Colors.white, size: 16), Gap(4.w), Text('${_batchCodes.length} scanned', style: TextStyles.captionBold.copyWith(color: Colors.white))])))),
        if (_showManualEntry) Positioned(bottom: 120.h, left: 16.w, right: 16.w, child: Material(elevation: 8, borderRadius: BorderRadius.circular(12.r), child: Container(padding: EdgeInsets.all(16.w), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)), child: Column(mainAxisSize: MainAxisSize.min, children: [Row(children: [const Icon(Icons.keyboard, color: AppColors.accent), Gap(8.w), Text('Enter Code Manually', style: TextStyles.heading6), const Spacer(), IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _showManualEntry = false), padding: EdgeInsets.zero, constraints: const BoxConstraints())]), Gap(8.h), TextField(controller: _manualEntryController, autofocus: true, textCapitalization: TextCapitalization.characters, decoration: InputDecoration(hintText: 'Type or paste barcode / numeric code...', prefixIcon: const Icon(Icons.qr_code), suffixIcon: IconButton(icon: const Icon(Icons.send, color: AppColors.accent), onPressed: _submitManualEntry), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)), filled: true, fillColor: AppColors.gray50), onSubmitted: (_) => _submitManualEntry()), Gap(8.h), SizedBox(width: double.infinity, child: PrimaryButton(text: 'Submit Code', onPressed: _submitManualEntry, backgroundColor: AppColors.accent, height: 40.h))])))),
        Positioned(bottom: 32.h, left: 0, right: 0, child: SafeArea(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [TorchButton(isTorchOn: _isTorchOn, onToggle: () => _toggleTorch()), Gap(24.w), if (_isBatchMode && _batchCodes.isNotEmpty) FloatingActionButton(heroTag: 'batch_clear', onPressed: () => setState(() => _batchCodes.clear()), backgroundColor: AppColors.warning, mini: true, child: const Icon(Icons.clear_all, color: Colors.white)), if (_isBatchMode && _batchCodes.isNotEmpty) Gap(16.w), FloatingActionButton(heroTag: 'scanner_close', onPressed: () { if (_isBatchMode && _batchCodes.isNotEmpty) context.pop(_batchCodes); else context.pop(); }, backgroundColor: AppColors.error, child: const Icon(Icons.close, color: Colors.white))]))),
      ]),
    );
  }

  Widget _buildError(String error) => Container(color: Colors.black, child: Center(child: Padding(padding: EdgeInsets.all(24.w), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.camera_alt, size: 64, color: AppColors.error), Gap(16.h), Text('Camera Unavailable', style: TextStyles.heading6.copyWith(color: Colors.white)), Gap(8.h), Text(error, style: TextStyles.caption.copyWith(color: Colors.white70), textAlign: TextAlign.center), Gap(24.h), PrimaryButton(text: 'Use Manual Entry', onPressed: () => setState(() => _showManualEntry = true), backgroundColor: AppColors.accent), Gap(12.h), TextButton(onPressed: () => _cameraController.start(), child: const Text('Retry Camera', style: TextStyle(color: Colors.white70)))]))));
}
