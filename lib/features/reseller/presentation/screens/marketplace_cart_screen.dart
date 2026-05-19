import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nexatrace_system/core/constants/api_endpoints.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/features/reseller/presentation/bloc/cart/reseller_cart_bloc.dart';
import 'package:nexatrace_system/features/reseller/presentation/bloc/marketplace/reseller_marketplace_bloc.dart';
import 'package:nexatrace_system/features/reseller/presentation/bloc/order/reseller_order_bloc.dart';
import 'package:nexatrace_system/shared/models/order/cart_item_model.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/empty_states/empty_state_widget.dart';

class MarketplaceCartScreen extends StatefulWidget {
  const MarketplaceCartScreen({super.key});

  @override
  State<MarketplaceCartScreen> createState() => _MarketplaceCartScreenState();
}

class _MarketplaceCartScreenState extends State<MarketplaceCartScreen> {
  bool _businessVerified = true;
  String? _placingFactoryId;
  PlatformFile? _proofFile;
  final _proofTitleController = TextEditingController();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBusinessProof();
    });
  }

  @override
  void dispose() {
    _proofTitleController.dispose();
    super.dispose();
  }

  Future<void> _checkBusinessProof() async {
    try {
      final res = await ApiService().get(
        ApiEndpoints.resellerProofStatus,
        requiresAuth: true,
      );
      final data = res is Map ? res : (res['data'] is Map ? res['data'] : null);
      final approved = data?['purchase_approved'] == true;
      if (mounted) setState(() => _businessVerified = approved);
    } catch (_) {
      // Fallback: allow if API unavailable
      if (mounted) setState(() => _businessVerified = true);
    }
  }

  // ── Factory name lookup ──────────────────────────────────────────
  String _factoryName(String factoryId) {
    final factories = context.read<ResellerMarketplaceBloc>().state.factories;
    for (final f in factories) {
      if (f['id']?.toString() == factoryId) {
        return f['name']?.toString() ?? factoryId;
      }
    }
    return factoryId;
  }

  String _productName(CartItemModel item) {
    return item.metadata?['product_name']?.toString() ?? item.productId;
  }

  // ── Place order action ───────────────────────────────────────────
  void _onPlaceOrder(String factoryId, List<CartItemModel> items) {
    if (!_businessVerified) {
      _showVerificationModal();
      return;
    }

    final marketplace = context.read<ResellerMarketplaceBloc>().state;
    final tenantId = marketplace.tenantId;

    // Reseller ID from the dashboard bloc or prefs
    String resellerId = '';
    try {
      resellerId =
          context
              .read<ResellerMarketplaceBloc>()
              .state
              .factories
              .first['reseller_id']
              ?.toString() ??
          '';
    } catch (_) {}

    if (tenantId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please re-login.')),
      );
      return;
    }

    setState(() => _placingFactoryId = factoryId);

    context.read<ResellerOrderBloc>().add(
      PlaceOrderRequested(
        tenantId: tenantId,
        factoryId: factoryId,
        resellerId: resellerId,
        items: items,
        factoryName: _factoryName(factoryId),
      ),
    );
  }

  void _showVerificationModal() {
    _proofFile = null;
    _proofTitleController.clear();
    _isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 20.h,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              Icon(Icons.verified_user, size: 48.sp, color: AppColors.warning),
              SizedBox(height: 12.h),
              Text(
                'Verification Required',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8.h),
              Text(
                'Upload a business proof document (license, registration, tax certificate) to unlock purchasing.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.gray600),
              ),
              SizedBox(height: 16.h),
              // ── File picker button ────────────────────
              GestureDetector(
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                    allowMultiple: false,
                  );
                  if (result?.files.isNotEmpty == true) {
                    setSheetState(() => _proofFile = result!.files.first);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _proofFile != null
                            ? Icons.check_circle
                            : Icons.cloud_upload_outlined,
                        size: 32.sp,
                        color: _proofFile != null
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        _proofFile?.name ?? 'Tap to select document',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray700,
                        ),
                      ),
                      if (_proofFile != null)
                        Text(
                          '${(_proofFile!.size / 1024).toStringAsFixed(0)} KB',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.gray400,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              // ── Title field ────────────────────────────
              TextField(
                controller: _proofTitleController,
                decoration: InputDecoration(
                  labelText: 'Document Title / Description',
                  hintText: 'e.g. Business Registration Certificate',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // ── Upload button ─────────────────────────
              PrimaryButton(
                text: _isUploading ? 'Uploading…' : 'Submit for Approval',
                isLoading: _isUploading,
                isEnabled:
                    _proofFile != null &&
                    _proofTitleController.text.trim().isNotEmpty &&
                    !_isUploading,
                onPressed: () async {
                  if (_proofFile == null ||
                      _proofTitleController.text.trim().isEmpty)
                    return;
                  setSheetState(() => _isUploading = true);
                  try {
                    await ApiService().uploadFile(
                      ApiEndpoints.resellerProofUpload,
                      _proofFile!.path!,
                      'proof_file',
                      fields: {
                        'document_title': _proofTitleController.text.trim(),
                      },
                    );
                    if (mounted) {
                      setState(
                        () => _businessVerified = false,
                      ); // Still needs admin approval
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Document submitted! Awaiting admin approval.',
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                    Navigator.pop(sheetCtx);
                  } catch (e) {
                    setSheetState(() => _isUploading = false);
                    ScaffoldMessenger.of(sheetCtx).showSnackBar(
                      SnackBar(
                        content: Text('Upload failed: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () => Navigator.pop(sheetCtx),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Order success / failure listener ────────────────────────────
  void _listenOrderResult(BuildContext context, ResellerOrderState state) {
    if (_placingFactoryId == null) return;

    // Success
    if (state.status == OrderStatus.success && state.lastPlacedOrder != null) {
      final factoryId = _placingFactoryId!;
      final order = state.lastPlacedOrder!;
      final factoryName =
          state.lastPlacedFactoryName ?? _factoryName(factoryId);

      context.read<ResellerCartBloc>().add(ClearCart(factoryId: factoryId));
      setState(() => _placingFactoryId = null);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 28.sp),
              SizedBox(width: 8.w),
              const Text('Order Placed!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your order has been sent to $factoryName.'),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Order ID: ${order.id}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/marketplace/orders');
              },
              child: const Text('View Orders'),
            ),
            PrimaryButton(
              text: 'Continue Shopping',
              onPressed: () {
                Navigator.pop(context);
                context.go('/marketplace');
              },
            ),
          ],
        ),
      );
      return;
    }

    // Failure
    if (state.status == OrderStatus.failure) {
      setState(() => _placingFactoryId = null);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              state.errorMessage ?? 'Order failed. Please try again.',
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Your Cart', showBackButton: true),
      body: BlocListener<ResellerOrderBloc, ResellerOrderState>(
        listener: _listenOrderResult,
        child: BlocBuilder<ResellerCartBloc, ResellerCartState>(
          builder: (context, cart) {
            if (cart.itemsByFactory.isEmpty) {
              return EmptyState(
                title: 'Cart is Empty',
                description:
                    'You haven\'t added any products yet.\nBrowse factories and add items to your cart.',
                icon: Icons.shopping_cart_outlined,
                actionButton: PrimaryButton(
                  text: 'Go Back to Shopping',
                  onPressed: () => context.go('/marketplace'),
                ),
              );
            }

            final entries = cart.itemsByFactory.entries.toList();

            return Column(
              children: [
                // ── Summary strip ───────────────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  color: AppColors.gray50,
                  child: Text(
                    '${cart.itemCount} items • '
                    'Total: ${cart.totalAmount.toStringAsFixed(0)} PKR',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // ── Factory groups ──────────────────────────────
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 100.h),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => SizedBox(height: 14.h),
                    itemBuilder: (_, i) {
                      final factoryId = entries[i].key;
                      final items = entries[i].value;
                      return _factoryGroup(factoryId, items, cart);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Factory group card ───────────────────────────────────────────
  Widget _factoryGroup(
    String factoryId,
    List<CartItemModel> items,
    ResellerCartState cart,
  ) {
    final subtotal = cart.subtotalsByFactory[factoryId] ?? 0.0;
    final isPlacing = _placingFactoryId == factoryId;
    final blocState = context.read<ResellerOrderBloc>().state;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Factory header ────────────────────────────────
            Row(
              children: [
                Icon(Icons.store, color: AppColors.primary, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _factoryName(factoryId),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            const Divider(),
            SizedBox(height: 4.h),

            // ── Line items ────────────────────────────────────
            ...items.map((item) => _lineItem(item, factoryId)),

            SizedBox(height: 8.h),
            const Divider(),
            SizedBox(height: 6.h),

            // ── Subtotal ──────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'PKR ${subtotal.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // ── Place Order button ────────────────────────────
            PrimaryButton(
              text: isPlacing
                  ? 'Placing Order…'
                  : 'Place Order → ${_factoryName(factoryId)}',
              isLoading: isPlacing,
              isEnabled: !isPlacing,
              onPressed: () => _onPlaceOrder(factoryId, items),
            ),

            // ── Error feedback ────────────────────────────────
            if (blocState.status == OrderStatus.failure &&
                blocState.errorMessage != null)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  blocState.errorMessage!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.error),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Single line item ─────────────────────────────────────────────
  Widget _lineItem(CartItemModel item, String factoryId) {
    final name = _productName(item);
    final lineTotal = item.unitPrice * item.quantity;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          // ── Product info ───────────────────────────────────
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  '${item.unitPrice.toStringAsFixed(0)} × ${item.quantity} = ${lineTotal.toStringAsFixed(0)} PKR',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.gray500,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),

          // ── Quantity controls ──────────────────────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _qtyButton(Icons.remove, () {
                context.read<ResellerCartBloc>().add(
                  UpdateQuantity(
                    productId: item.productId,
                    factoryId: factoryId,
                    newQuantity: item.quantity - 1,
                  ),
                );
              }),
              SizedBox(
                width: 28.w,
                child: Text(
                  '${item.quantity}',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              _qtyButton(Icons.add, () {
                context.read<ResellerCartBloc>().add(
                  UpdateQuantity(
                    productId: item.productId,
                    factoryId: factoryId,
                    newQuantity: item.quantity + 1,
                  ),
                );
              }),
            ],
          ),

          SizedBox(width: 8.w),

          // ── Remove button ──────────────────────────────────
          InkWell(
            onTap: () {
              context.read<ResellerCartBloc>().add(
                RemoveFromCart(productId: item.productId, factoryId: factoryId),
              );
            },
            borderRadius: BorderRadius.circular(6.r),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Icon(
                Icons.delete_outline,
                size: 18.sp,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        width: 28.w,
        height: 28.h,
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(icon, size: 16.sp, color: AppColors.gray700),
      ),
    );
  }
}
