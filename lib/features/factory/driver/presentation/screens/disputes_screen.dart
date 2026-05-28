import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:trace_odd/features/factory/driver/presentation/bloc/driver_bloc.dart';
import 'package:trace_odd/features/factory/driver/domain/entities/trip.dart';
import 'package:trace_odd/features/factory/driver/presentation/widgets/driver_feature_scaffold.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';
import 'package:trace_odd/shared/widgets/inputs/custom_text_field.dart';

class DriverDisputesScreen extends StatefulWidget {
  const DriverDisputesScreen({super.key});

  @override
  State<DriverDisputesScreen> createState() => _DriverDisputesScreenState();
}

class _DriverDisputesScreenState extends State<DriverDisputesScreen> {
  String? _expandedId;
  final Map<String, TextEditingController> _evidenceControllers = {};

  @override
  void initState() {
    super.initState();
    context.read<DriverBloc>().add(const LoadDisputes());
  }

  @override
  void dispose() {
    for (final c in _evidenceControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(String disputeId) {
    if (!_evidenceControllers.containsKey(disputeId)) {
      _evidenceControllers[disputeId] = TextEditingController();
    }
    return _evidenceControllers[disputeId]!;
  }

  void _toggleExpand(String id) {
    setState(() {
      _expandedId = _expandedId == id ? null : id;
    });
  }

  void _submitEvidence(String disputeId) {
    final ctrl = _getController(disputeId);
    final text = ctrl.text.trim();
    if (text.isEmpty) return;

    context.read<DriverBloc>().add(
      SubmitDisputeEvidence(disputeId: disputeId, counterEvidence: text),
    );
    ctrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Counter evidence submitted'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Color _statusColor(DisputeStatus status) {
    return switch (status) {
      DisputeStatus.open => AppColors.error,
      DisputeStatus.underReview => AppColors.warning,
      DisputeStatus.resolved => AppColors.success,
      DisputeStatus.escalated => AppColors.accent,
    };
  }

  String _statusLabel(DisputeStatus status) {
    return status.displayName;
  }

  bool _isEscalated(DateTime? date) {
    if (date == null) return false;
    return DateTime.now().difference(date).inHours > 24;
  }

  @override
  Widget build(BuildContext context) {
    return DriverFeatureScaffold(
      title: 'Disputes',
      child: BlocBuilder<DriverBloc, DriverState>(
        builder: (context, state) {
          if (state is DriverLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state is! DisputesLoaded) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final disputes = state.disputes;

          if (disputes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.gavel_outlined,
                    size: 52.sp,
                    color: AppColors.gray400,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'No disputes',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'You have no active disputes',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            );
          }

          // Summary
          final openCount = disputes
              .where((d) => d.status == DisputeStatus.open)
              .length;
          final unresolvedCount = disputes
              .where(
                (d) =>
                    d.status != DisputeStatus.resolved &&
                    _isEscalated(d.createdAt),
              )
              .length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary row
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _statChip('Open', '$openCount', AppColors.error),
                    SizedBox(width: 12.w),
                    _statChip('Total', '${disputes.length}', AppColors.primary),
                    if (unresolvedCount > 0) ...[
                      SizedBox(width: 12.w),
                      _statChip(
                        'Escalated',
                        '$unresolvedCount',
                        AppColors.accent,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              // Escalation notice
              if (unresolvedCount > 0)
                Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.report_problem,
                        color: AppColors.accent,
                        size: 20.sp,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          '$unresolvedCount dispute(s) unresolved for >24 hours. Escalation notice triggered (4AB).',
                          style: TextStyle(
                            color: AppColors.accent.withOpacity(0.9),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // Dispute list
              ...disputes.map((dispute) {
                final id = dispute.id;
                final tripId = dispute.tripId;
                final customer = 'Driver #${dispute.driverId}';
                final reason = dispute.reason;
                final status = dispute.status;
                final date = dispute.createdAt;
                final evidence = dispute.evidence ?? '';
                final counterEvidence = dispute.counterEvidence;
                final isExpanded = _expandedId == id;
                final isEscalated = _isEscalated(date);
                final statusClr = _statusColor(status);

                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isEscalated && status != DisputeStatus.resolved
                          ? AppColors.accent.withOpacity(0.5)
                          : AppColors.border,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 4.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => _toggleExpand(id),
                        borderRadius: BorderRadius.circular(14.r),
                        child: Padding(
                          padding: EdgeInsets.all(14.w),
                          child: Row(
                            children: [
                              Container(
                                width: 44.w,
                                height: 44.w,
                                decoration: BoxDecoration(
                                  color: statusClr.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(
                                  Icons.gavel,
                                  color: statusClr,
                                  size: 22,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Trip #$tripId',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 3.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusClr.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(
                                              4.r,
                                            ),
                                          ),
                                          child: Text(
                                            _statusLabel(status),
                                            style: TextStyle(
                                              color: statusClr,
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      customer,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      reason,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.textTertiary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 4.h),
                                      child: Text(
                                        DateFormat(
                                          'MMM d, yyyy – h:mm a',
                                        ).format(date),
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Expanded section
                      if (isExpanded)
                        Container(
                          padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(color: AppColors.border),
                              SizedBox(height: 8.h),
                              // Evidence summary
                              Text(
                                'Evidence Summary',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.sp,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: AppColors.gray50,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  evidence.isNotEmpty
                                      ? evidence
                                      : 'No evidence provided',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              if (counterEvidence != null &&
                                  counterEvidence.isNotEmpty) ...[
                                SizedBox(height: 10.h),
                                Text(
                                  'Your Counter Evidence',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.sp,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Text(
                                    counterEvidence,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                              if (status != DisputeStatus.resolved) ...[
                                SizedBox(height: 14.h),
                                Text(
                                  'Submit Counter Evidence',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.sp,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                CustomTextField(
                                  controller: _getController(id),
                                  labelText: 'Describe your side…',
                                  maxLines: 3,
                                ),
                                SizedBox(height: 10.h),
                                PrimaryButton(
                                  text: 'Submit Counter Evidence',
                                  onPressed: () => _submitEvidence(id),
                                  height: 42.h,
                                  borderRadius: 8.r,
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }),
              // Refresh
              SizedBox(height: 8.h),
              PrimaryButton(
                text: 'Refresh Disputes',
                onPressed: () {
                  context.read<DriverBloc>().add(const LoadDisputes());
                },
                height: 44.h,
                borderRadius: 10.r,
                backgroundColor: AppColors.textSecondary,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
