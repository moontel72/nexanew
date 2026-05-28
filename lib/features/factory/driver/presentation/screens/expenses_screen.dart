import 'package:file_picker/file_picker.dart';
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

class DriverExpensesScreen extends StatefulWidget {
  const DriverExpensesScreen({super.key});

  @override
  State<DriverExpensesScreen> createState() => _DriverExpensesScreenState();
}

class _DriverExpensesScreenState extends State<DriverExpensesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DriverBloc>().add(const LoadExpenses());
  }

  void _showAddExpenseSheet() {
    final bloc = context.read<DriverBloc>();
    String selectedType = 'fuel';
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    PlatformFile? receiptFile;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 20.h,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: AppColors.gray300,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Add Expense',
                        style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      // Type Dropdown
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(10.r),
                          color: AppColors.inputBackground,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedType,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'fuel',
                                child: Text('⛽ Fuel'),
                              ),
                              DropdownMenuItem(
                                value: 'food',
                                child: Text('🍔 Food'),
                              ),
                              DropdownMenuItem(
                                value: 'mechanic',
                                child: Text('🔧 Mechanic'),
                              ),
                              DropdownMenuItem(
                                value: 'other',
                                child: Text('📦 Other'),
                              ),
                            ],
                            onChanged: (v) {
                              setSheetState(() => selectedType = v!);
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      // Amount
                      CustomTextField(
                        controller: amountCtrl,
                        labelText: 'Amount (\$)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Amount is required';
                          }
                          final amt = double.tryParse(v.trim());
                          if (amt == null || amt <= 0) {
                            return 'Enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 14.h),
                      // Receipt upload
                      InkWell(
                        onTap: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.image,
                            allowMultiple: false,
                          );
                          if (result?.files.isNotEmpty == true) {
                            setSheetState(
                              () => receiptFile = result!.files.first,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: receiptFile != null
                                  ? AppColors.success
                                  : AppColors.border,
                            ),
                            borderRadius: BorderRadius.circular(10.r),
                            color: receiptFile != null
                                ? AppColors.success.withOpacity(0.06)
                                : AppColors.surface,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                receiptFile != null
                                    ? Icons.check_circle
                                    : Icons.receipt_long_outlined,
                                color: receiptFile != null
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  receiptFile != null
                                      ? receiptFile!.name
                                      : 'Upload Receipt (optional)',
                                  style: TextStyle(
                                    color: receiptFile != null
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      // Notes
                      CustomTextField(
                        controller: notesCtrl,
                        labelText: 'Notes (optional)',
                        maxLines: 3,
                      ),
                      SizedBox(height: 20.h),
                      // Submit
                      PrimaryButton(
                        text: 'Submit Expense',
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            final amount = double.parse(amountCtrl.text.trim());
                            final expType = ExpenseType.values.firstWhere(
                              (e) => e.name == selectedType,
                              orElse: () => ExpenseType.other,
                            );
                            bloc.add(
                              SubmitExpense(
                                type: expType,
                                amount: amount,
                                receiptPath: receiptFile?.path,
                                notes: notesCtrl.text.trim().isNotEmpty
                                    ? notesCtrl.text.trim()
                                    : null,
                              ),
                            );
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Expense submitted!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _iconForExpenseType(ExpenseType type) {
    switch (type) {
      case ExpenseType.fuel:
        return Icons.local_gas_station;
      case ExpenseType.food:
        return Icons.fastfood;
      case ExpenseType.mechanic:
        return Icons.build;
      case ExpenseType.other:
        return Icons.receipt_long;
    }
  }

  String _titleForExpenseType(ExpenseType type) {
    switch (type) {
      case ExpenseType.fuel:
        return 'Fuel';
      case ExpenseType.food:
        return 'Food';
      case ExpenseType.mechanic:
        return 'Mechanic';
      case ExpenseType.other:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DriverFeatureScaffold(
      title: 'Expenses',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary card
          BlocBuilder<DriverBloc, DriverState>(
            builder: (context, state) {
              if (state is! ExpensesLoaded) {
                return const SizedBox.shrink();
              }
              final expenses = state.expenses;
              final double total = expenses.fold<double>(
                0,
                (sum, e) => sum + e.amount,
              );
              final double pendingTotal = expenses
                  .where((e) => e.needsAdminApproval)
                  .fold<double>(0, (sum, e) => sum + e.amount);

              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryItem('Total', '\$${total.toStringAsFixed(2)}'),
                        _summaryItem(
                          'Pending',
                          '\$${pendingTotal.toStringAsFixed(2)}',
                          color: AppColors.warning,
                        ),
                      ],
                    ),
                    if (pendingTotal > 0) ...[
                      SizedBox(height: 10.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.error,
                              size: 18.sp,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                'Unapproved optional expenses require admin approval (4N). Admin will be notified.',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 20.h),
          // List header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expense History',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              PrimaryButton(
                text: '+ Add Expense',
                onPressed: _showAddExpenseSheet,
                width: 150.w,
                height: 40.h,
                borderRadius: 8.r,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Expense list
          BlocBuilder<DriverBloc, DriverState>(
            builder: (context, state) {
              if (state is DriverLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is! ExpensesLoaded) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 50.h),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48.sp,
                        color: AppColors.gray400,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'No expenses recorded yet',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state.expenses.isEmpty) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 50.h),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48.sp,
                        color: AppColors.gray400,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'No expenses recorded yet',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final expenses = state.expenses;
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: expenses.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final exp = expenses[index];
                  final type = exp.type;
                  final amount = exp.amount;
                  final notes = exp.notes;
                  final date = exp.submittedAt;
                  final needsApproval = exp.needsAdminApproval;
                  final icon = _iconForExpenseType(type);
                  final title = _titleForExpenseType(type);

                  return Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: needsApproval
                            ? AppColors.error.withOpacity(0.4)
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(icon, color: AppColors.primary, size: 22),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  if (needsApproval) ...[
                                    SizedBox(width: 8.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withOpacity(
                                          0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
                                      ),
                                      child: Text(
                                        'UNAPPROVED',
                                        style: TextStyle(
                                          color: AppColors.error,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (notes != null && notes.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 4.h),
                                  child: Text(
                                    notes,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
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
                        Text(
                          '\$${amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
