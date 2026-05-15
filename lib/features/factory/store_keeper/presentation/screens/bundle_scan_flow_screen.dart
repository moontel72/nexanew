import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/theme/text_styles.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';

enum ScanFlowStep { bundle, carton, packet, unit, complete }

class BundleScanFlowScreen extends StatefulWidget {
  final String bundleId;

  const BundleScanFlowScreen({super.key, required this.bundleId});

  @override
  State<BundleScanFlowScreen> createState() => _BundleScanFlowScreenState();
}

class _BundleScanFlowScreenState extends State<BundleScanFlowScreen> {
  final ApiService _apiService = ApiService();

  ScanFlowStep _currentStep = ScanFlowStep.bundle;
  bool _isProcessing = false;

  String? _bundleCode;
  String? _cartonCode;
  String? _packetCode;
  String? _unitCode;

  final List<_ScanStepEntry> _completedSteps = [];

  @override
  void initState() {
    super.initState();
    _advanceToNextStep();
  }

  void _advanceToNextStep() {
    if (_currentStep == ScanFlowStep.complete) return;

    final nextLabels = <ScanFlowStep, String>{
      ScanFlowStep.bundle: 'Scan Bundle QR',
      ScanFlowStep.carton: 'Scan Carton QR',
      ScanFlowStep.packet: 'Scan Packet QR',
      ScanFlowStep.unit: 'Scan Unit QR',
    };

    final label = nextLabels[_currentStep] ?? 'Scan Code';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(label),
        backgroundColor: AppColors.accent,
        duration: const Duration(seconds: 1),
      ),
    );

    _openScannerForCurrentStep();
  }

  Future<void> _openScannerForCurrentStep() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    final result = await context.push<String>('/factory/store-keeper/scanner');

    if (result == null || result.isEmpty) {
      if (mounted) setState(() => _isProcessing = false);
      return;
    }

    await _processScannedCode(result);
  }

  Future<void> _processScannedCode(String code) async {
    try {
      switch (_currentStep) {
        case ScanFlowStep.bundle:
          await _handleBundleScan(code);
          break;
        case ScanFlowStep.carton:
          await _handleCartonScan(code);
          break;
        case ScanFlowStep.packet:
          await _handlePacketScan(code);
          break;
        case ScanFlowStep.unit:
          await _handleUnitScan(code);
          break;
        case ScanFlowStep.complete:
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing scan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleBundleScan(String code) async {
    setState(() {
      _bundleCode = code;
      _completedSteps.add(
        _ScanStepEntry(step: ScanFlowStep.bundle, code: code, label: 'Bundle'),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bundle scanned: $code'),
        backgroundColor: AppColors.success,
      ),
    );

    setState(() {
      _currentStep = ScanFlowStep.carton;
      _isProcessing = false;
    });
    _advanceToNextStep();
  }

  Future<void> _handleCartonScan(String code) async {
    // Link carton to bundle via API
    await _apiService.post(
      '/factory/store-keeper-bundles/${widget.bundleId}/link-carton',
      body: {'carton_code_id': code},
    );

    setState(() {
      _cartonCode = code;
      _completedSteps.add(
        _ScanStepEntry(step: ScanFlowStep.carton, code: code, label: 'Carton'),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Carton linked: $code'),
        backgroundColor: AppColors.success,
      ),
    );

    setState(() {
      _currentStep = ScanFlowStep.packet;
      _isProcessing = false;
    });
    _advanceToNextStep();
  }

  Future<void> _handlePacketScan(String code) async {
    // Link packet to bundle via API
    await _apiService.post(
      '/factory/store-keeper-bundles/${widget.bundleId}/link-packet',
      body: {'packet_code_id': code},
    );

    setState(() {
      _packetCode = code;
      _completedSteps.add(
        _ScanStepEntry(step: ScanFlowStep.packet, code: code, label: 'Packet'),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Packet linked: $code'),
        backgroundColor: AppColors.success,
      ),
    );

    setState(() {
      _currentStep = ScanFlowStep.unit;
      _isProcessing = false;
    });
    _advanceToNextStep();
  }

  Future<void> _handleUnitScan(String code) async {
    // Link unit to bundle via API — include packet_code_id from previous step
    final unitBody = <String, dynamic>{'unit_code_id': code};
    if (_packetCode != null && _packetCode!.isNotEmpty) {
      unitBody['packet_code_id'] = _packetCode;
    }
    await _apiService.post(
      '/factory/store-keeper-bundles/${widget.bundleId}/link-unit',
      body: unitBody,
    );

    setState(() {
      _unitCode = code;
      _completedSteps.add(
        _ScanStepEntry(step: ScanFlowStep.unit, code: code, label: 'Unit'),
      );
    });

    // Mark the bundle as complete
    await _apiService.put(
      '/factory/store-keeper-bundles/${widget.bundleId}/linking-status',
      body: {'linking_status': 'store_linked'},
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unit linked: $code — Bundle complete!'),
        backgroundColor: AppColors.success,
      ),
    );

    setState(() {
      _currentStep = ScanFlowStep.complete;
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentStep == ScanFlowStep.complete
              ? 'Scan Flow Complete'
              : 'Guided Scan Flow',
        ),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/factory/store-keeper/dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Step Indicator ──
            _buildStepIndicator(),
            Gap(24.h),

            // ── Current Step Card ──
            _buildCurrentStepCard(),
            Gap(16.h),

            // ── Completed Steps ──
            if (_completedSteps.isNotEmpty) ...[
              _buildCompletedStepsCard(),
              Gap(16.h),
            ],

            // ── Navigation Buttons ──
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = [
      _StepInfo('Bundle', Icons.inventory_2, ScanFlowStep.bundle),
      _StepInfo('Carton', Icons.inventory, ScanFlowStep.carton),
      _StepInfo('Packet', Icons.archive, ScanFlowStep.packet),
      _StepInfo('Unit', Icons.circle, ScanFlowStep.unit),
    ];

    final currentIdx = steps.indexWhere((s) => s.step == _currentStep);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              children: List.generate(steps.length, (i) {
                final done =
                    i < currentIdx || (currentIdx < 0 && i < steps.length);
                final cur = i == currentIdx;
                return Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done
                              ? AppColors.success
                              : cur
                              ? AppColors.accent
                              : AppColors.gray300,
                        ),
                        child: Center(
                          child: done
                              ? Icon(
                                  Icons.check,
                                  size: 16.w,
                                  color: Colors.white,
                                )
                              : Text(
                                  '${i + 1}',
                                  style: TextStyles.captionBold.copyWith(
                                    color: cur
                                        ? Colors.white
                                        : AppColors.gray500,
                                  ),
                                ),
                        ),
                      ),
                      if (i < steps.length - 1)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: done ? AppColors.success : AppColors.gray300,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
            Gap(8.h),
            Row(
              children: steps
                  .map(
                    (s) => Expanded(
                      child: Text(
                        s.label,
                        style: TextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepCard() {
    if (_currentStep == ScanFlowStep.complete) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 36.w,
                  color: AppColors.success,
                ),
              ),
              Gap(16.h),
              Text(
                'All Steps Complete!',
                style: TextStyles.heading5.copyWith(color: AppColors.success),
              ),
              Gap(8.h),
              Text(
                'Bundle, Carton, Packet, and Unit have been linked successfully.',
                style: TextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final stepLabels = <ScanFlowStep, String>{
      ScanFlowStep.bundle: 'Scan Bundle QR',
      ScanFlowStep.carton: 'Scan Carton QR',
      ScanFlowStep.packet: 'Scan Packet QR',
      ScanFlowStep.unit: 'Scan Unit QR',
    };

    final stepIcons = <ScanFlowStep, IconData>{
      ScanFlowStep.bundle: Icons.inventory_2,
      ScanFlowStep.carton: Icons.inventory,
      ScanFlowStep.packet: Icons.archive,
      ScanFlowStep.unit: Icons.circle,
    };

    final label = stepLabels[_currentStep] ?? 'Scan Code';
    final icon = stepIcons[_currentStep] ?? Icons.qr_code_scanner;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.accent, size: 24.w),
                Gap(8.w),
                Text(label, style: TextStyles.heading6),
              ],
            ),
            Gap(12.h),
            Text(
              'Tap the button below to open the scanner and scan the required QR code.',
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Gap(16.h),
            PrimaryButton(
              text: _isProcessing ? 'Scanning...' : label,
              isEnabled: !_isProcessing,
              onPressed: () {
                _openScannerForCurrentStep();
              },
              backgroundColor: AppColors.accent,
              icon: Icons.qr_code_scanner,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedStepsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.checklist, color: AppColors.accent, size: 24.w),
                Gap(8.w),
                Text('Completed Steps', style: TextStyles.heading6),
              ],
            ),
            Gap(12.h),
            ..._completedSteps.map((entry) => _completedStepTile(entry)),
          ],
        ),
      ),
    );
  }

  Widget _completedStepTile(_ScanStepEntry entry) {
    final stepIcons = <ScanFlowStep, IconData>{
      ScanFlowStep.bundle: Icons.inventory_2,
      ScanFlowStep.carton: Icons.inventory,
      ScanFlowStep.packet: Icons.archive,
      ScanFlowStep.unit: Icons.circle,
    };

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              stepIcons[entry.step] ?? Icons.check,
              size: 18.w,
              color: AppColors.success,
            ),
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.label, style: TextStyles.captionBold),
                Text(
                  entry.code,
                  style: TextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: AppColors.success, size: 20.w),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Column(
      children: [
        if (_currentStep == ScanFlowStep.complete) ...[
          PrimaryButton(
            text: 'Back to Bundle',
            onPressed: () => context.pop(),
            backgroundColor: AppColors.accent,
          ),
        ] else ...[
          OutlinedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Cancel Flow'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ],
      ],
    );
  }
}

class _StepInfo {
  final String label;
  final IconData icon;
  final ScanFlowStep step;

  const _StepInfo(this.label, this.icon, this.step);
}

class _ScanStepEntry {
  final ScanFlowStep step;
  final String code;
  final String label;

  const _ScanStepEntry({
    required this.step,
    required this.code,
    required this.label,
  });
}
