import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/factory/store_keeper/presentation/bloc/store_keeper_bloc.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/theme/text_styles.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';

class LinkingScreen extends StatefulWidget {
  const LinkingScreen({super.key});
  @override
  State<LinkingScreen> createState() => _LinkingScreenState();
}

class _LinkingScreenState extends State<LinkingScreen> {
  final _codeC = TextEditingController();
  String? _bundleId;
  String? _cartonId;
  String? _packetId;
  String _step = 'bundle';
  @override
  void dispose() {
    _codeC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoreKeeperBloc, StoreKeeperState>(
      listener: (context, state) {
        if (state is LinkingState)
          setState(() {
            _bundleId = state.currentBundleId ?? _bundleId;
            _cartonId = state.currentCartonId ?? _cartonId;
            _packetId = state.currentPacketId ?? _packetId;
            _step = state.linkingStep;
          });
        if (state is ErrorState)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Link Items'),
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.home), onPressed: () => context.go('/factory/store-keeper/dashboard')),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _stepIndicator(),
              Gap(24.h),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        {
                              'bundle': 'Scan Bundle Code',
                              'carton': 'Scan Carton Code',
                              'packet': 'Scan Packet Code',
                              'unit': 'Scan Unit Code',
                            }[_step] ??
                            'Enter Code',
                        style: TextStyles.heading6,
                      ),
                      Gap(12.h),
                      TextField(
                        controller: _codeC,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            {
                              'bundle': Icons.inventory_2,
                              'carton': Icons.inventory,
                              'packet': Icons.archive,
                              'unit': Icons.circle,
                            }[_step],
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _submit,
                          ),
                          hintText: 'Enter or scan code...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        onSubmitted: (_) => _submit(),
                      ),
                      Gap(12.h),
                      PrimaryButton(
                        text:
                            {
                              'bundle': 'Set Bundle',
                              'carton': 'Link to Bundle',
                              'packet': 'Link to Carton',
                              'unit': 'Link to Packet',
                            }[_step] ??
                            'Submit',
                        onPressed: _submit,
                        backgroundColor: AppColors.accent,
                      ),
                    ],
                  ),
                ),
              ),
              Gap(16.h),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Linked Items', style: TextStyles.heading6),
                      Gap(12.h),
                      if (_bundleId != null)
                        _linked('Bundle', _bundleId!, Icons.inventory_2),
                      if (_cartonId != null)
                        _linked('Carton', _cartonId!, Icons.inventory),
                      if (_packetId != null)
                        _linked('Packet', _packetId!, Icons.archive),
                      if (_bundleId == null)
                        Center(
                          child: Text(
                            'Start by scanning a Bundle',
                            style: TextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Gap(24.h),
              OutlinedButton.icon(
                onPressed: () => context.push('/factory/store-keeper/scanner'),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Open Scanner'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepIndicator() {
    final steps = ['Bundle', 'Carton', 'Packet', 'Unit'];
    final idx = {'bundle': 0, 'carton': 1, 'packet': 2, 'unit': 3}[_step] ?? 0;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              children: List.generate(4, (i) {
                final done = i < idx;
                final cur = i == idx;
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
                      if (i < 3)
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
                        s,
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

  Widget _linked(String type, String code, IconData icon) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 18.w, color: AppColors.accent),
        ),
        Gap(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(type, style: TextStyles.captionBold),
              Text(
                code,
                style: TextStyles.bodySmall.copyWith(
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

  void _submit() {
    final code = _codeC.text.trim();
    if (code.isEmpty) return;
    final bloc = context.read<StoreKeeperBloc>();
    switch (_step) {
      case 'bundle':
        _bundleId = code;
        break;
      case 'carton':
        _cartonId = code;
        if (_bundleId != null)
          bloc.add(LinkBundleToCarton(bundleId: _bundleId!, cartonId: code));
        break;
      case 'packet':
        _packetId = code;
        if (_cartonId != null)
          bloc.add(LinkCartonToPacket(cartonId: _cartonId!, packetId: code));
        break;
      case 'unit':
        if (_packetId != null)
          bloc.add(
            LinkUnitToPacket(
              packetId: _packetId!,
              unitId: code,
              productId: '',
              quantity: 1,
            ),
          );
        break;
    }
    _codeC.clear();
    setState(() {
      switch (_step) {
        case 'bundle':
          _step = 'carton';
          break;
        case 'carton':
          _step = 'packet';
          break;
        case 'packet':
          _step = 'unit';
          break;
        case 'unit':
          _step = 'bundle';
          _bundleId = _cartonId = _packetId = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Full chain linked!'),
              backgroundColor: AppColors.success,
            ),
          );
          break;
      }
    });
  }
}
