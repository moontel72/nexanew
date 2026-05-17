import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/products/products_bloc.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsBloc>().add(const LoadProducts());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _goToCreate() {
    context.go('/factory/products/create');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Products',
        showBackButton: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: PrimaryButton(
              onPressed: _goToCreate,
              text: 'Create',
              icon: Icons.add,
              backgroundColor: AppColors.secondary,
              textColor: Colors.white,
            ),
          ),
        ],
      ),
      body: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          final isBusy =
              state.status == ProductsStatus.loading ||
              state.status == ProductsStatus.creating;
          if (isBusy) {
            return const Center(child: LoadingIndicator());
          }

          if (state.status == ProductsStatus.error) {
            return Center(
              child: EmptyState(
                title: 'Failed to load products',
                description: state.errorMessage ?? 'Unknown error',
                icon: Icons.error_outline,
                iconColor: AppColors.error,
                actionButton: PrimaryButton(
                  text: 'Retry',
                  icon: Icons.refresh,
                  backgroundColor: AppColors.secondary,
                  textColor: Colors.white,
                  onPressed: () =>
                      context.read<ProductsBloc>().add(const LoadProducts()),
                ),
              ),
            );
          }

          final products = state.products;
          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search products by name or SKU…',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.trim().isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<ProductsBloc>().add(
                                    const LoadProducts(),
                                  );
                                  setState(() {});
                                },
                                icon: const Icon(Icons.clear),
                              ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (q) {
                        context.read<ProductsBloc>().add(
                          LoadProducts(search: q),
                        );
                      },
                    ),
                  ),
                  if (products.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: EmptyState(
                        title: 'No products yet',
                        description:
                            'Create a product first. Unit codes can only be published after selecting a product.',
                        icon: Icons.inventory_2_outlined,
                        iconColor: AppColors.secondary,
                        actionButton: PrimaryButton(
                          text: 'Create Product',
                          icon: Icons.add,
                          backgroundColor: AppColors.secondary,
                          textColor: Colors.white,
                          onPressed: _goToCreate,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      padding: EdgeInsets.only(
                        left: 16.w,
                        right: 16.w,
                        bottom: 16.w,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      separatorBuilder: (_, _) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final p = products[index];
                        final typeLabel = p.requiresWarranty
                            ? 'Non Food/Medical (Warranty)'
                            : 'Food/Medical (Expiry)';

                        final currencySymbol = p.currency == 'USD'
                            ? '\$'
                            : p.currency == 'EUR'
                            ? '\u20AC'
                            : 'Rs.';
                        final formattedPrice = p.unitPrice != null
                            ? NumberFormat(
                                '#,##0',
                                'en_US',
                              ).format(p.unitPrice!)
                            : null;
                        final listed = p.marketplaceEnabled;

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            side: BorderSide(color: AppColors.border),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12.r),
                            onTap: () => context.go('/factory/products/edit/${p.id}'),
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Text('\uD83C\uDFF7'),
                                            SizedBox(width: 6.w),
                                            Expanded(
                                              child: Text(
                                                p.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: listed
                                              ? Colors.green.withValues(
                                                  alpha: 0.12,
                                                )
                                              : Colors.grey.withValues(
                                                  alpha: 0.12,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          border: Border.all(
                                            color: listed
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 8.w,
                                              height: 8.w,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: listed
                                                    ? Colors.green
                                                    : Colors.grey,
                                              ),
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              listed ? 'Listed' : 'Not Listed',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                    color: listed
                                                        ? Colors.green
                                                        : Colors.grey,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'SKU: ${p.sku}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                      ),
                                      Text(
                                        'MOQ: ${p.moq} units',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.textTertiary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (formattedPrice != null)
                                              Text(
                                                '$currencySymbol $formattedPrice / unit',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          AppColors.secondary,
                                                    ),
                                              )
                                            else
                                              Text(
                                                'Price not set',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: AppColors
                                                          .textTertiary,
                                                    ),
                                              ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              typeLabel,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        AppColors.textTertiary,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            if (p.requiresWarranty &&
                                                p.defaultWarrantyMonths != null)
                                              Text(
                                                'Default warranty: ${p.defaultWarrantyMonths} months',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: AppColors
                                                          .textTertiary,
                                                    ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Switch(
                                        value: listed,
                                        onChanged: (newValue) {
                                          context.read<ProductsBloc>().add(
                                            ToggleMarketplace(
                                              productId: p.id,
                                              enabled: newValue,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
