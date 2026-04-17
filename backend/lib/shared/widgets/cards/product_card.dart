// Product Card Widget for NexaTrace System
// This file contains the product card widget used throughout the application

import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class ProductCard extends StatelessWidget {
  final String productName;
  final String productCode;
  final String? productImage;
  final String productType;
  final String status;
  final int totalCodes;
  final int linkedCodes;
  final int publishedCodes;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isSelectable;
  final bool isSelected;
  final ValueChanged<bool>? onSelectionChanged;

  const ProductCard({
    super.key,
    required this.productName,
    required this.productCode,
    this.productImage,
    required this.productType,
    required this.status,
    this.totalCodes = 0,
    this.linkedCodes = 0,
    this.publishedCodes = 0,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isSelectable = false,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'inactive':
        return AppColors.warning;
      case 'draft':
        return AppColors.gray500;
      case 'published':
        return AppColors.primary;
      default:
        return AppColors.gray500;
    }
  }

  Color _getProductTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'food':
        return AppColors.foodProduct;
      case 'medical':
        return AppColors.medicalProduct;
      case 'other':
        return AppColors.otherProduct;
      default:
        return AppColors.gray500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isSelectable)
                    Checkbox(
                      value: isSelected,
                      onChanged: onSelectionChanged != null
                          ? (value) => onSelectionChanged!(value ?? false)
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                productName,
                                style: TextStyles.heading6.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: _getStatusColor(status),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyles.captionBold.copyWith(
                                  color: _getStatusColor(status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Code: $productCode',
                          style: TextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getProductTypeColor(productType).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _getProductTypeColor(productType),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      productType.toUpperCase(),
                      style: TextStyles.captionBold.copyWith(
                        color: _getProductTypeColor(productType),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (onEdit != null || onDelete != null)
                    Row(
                      children: [
                        if (onEdit != null)
                          IconButton(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        if (onDelete != null)
                          IconButton(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete_outlined, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (totalCodes > 0 || linkedCodes > 0 || publishedCodes > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCodeStat('Total', totalCodes, AppColors.primary),
                        _buildCodeStat(
                          'Linked',
                          linkedCodes,
                          AppColors.success,
                        ),
                        _buildCodeStat(
                          'Published',
                          publishedCodes,
                          AppColors.info,
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeStat(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyles.heading5.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// Product Card for Grid View
class ProductGridCard extends StatelessWidget {
  final String productName;
  final String productCode;
  final String? productImage;
  final String productType;
  final String status;
  final VoidCallback? onTap;
  final bool isSelected;

  const ProductGridCard({
    super.key,
    required this.productName,
    required this.productCode,
    this.productImage,
    required this.productType,
    required this.status,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Placeholder
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(8),
                  image: productImage != null
                      ? DecorationImage(
                          image: NetworkImage(productImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: productImage == null
                    ? Center(
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: AppColors.gray400,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                productName,
                style: TextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                productCode,
                style: TextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getProductTypeColor(
                          productType,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        productType,
                        style: TextStyles.caption.copyWith(
                          color: _getProductTypeColor(productType),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      shape: BoxShape.circle,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'inactive':
        return AppColors.warning;
      case 'draft':
        return AppColors.gray500;
      case 'published':
        return AppColors.primary;
      default:
        return AppColors.gray500;
    }
  }

  Color _getProductTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'food':
        return AppColors.foodProduct;
      case 'medical':
        return AppColors.medicalProduct;
      case 'other':
        return AppColors.otherProduct;
      default:
        return AppColors.gray500;
    }
  }
}

// Product Card with QR Code
class ProductCardWithQR extends StatelessWidget {
  final String productName;
  final String productCode;
  final String qrCodeData;
  final String productType;
  final String status;
  final VoidCallback? onTap;
  final VoidCallback? onScan;

  const ProductCardWithQR({
    super.key,
    required this.productName,
    required this.productCode,
    required this.qrCodeData,
    required this.productType,
    required this.status,
    this.onTap,
    this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // QR Code Placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gray300),
                ),
                child: Center(
                  child: Icon(
                    Icons.qr_code_2,
                    size: 40,
                    color: AppColors.gray400,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: TextStyles.heading6.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      productCode,
                      style: TextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getProductTypeColor(
                              productType,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _getProductTypeColor(productType),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            productType.toUpperCase(),
                            style: TextStyles.captionBold.copyWith(
                              color: _getProductTypeColor(productType),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onScan != null)
                IconButton(
                  onPressed: onScan,
                  icon: const Icon(Icons.qr_code_scanner, size: 24),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'inactive':
        return AppColors.warning;
      case 'draft':
        return AppColors.gray500;
      case 'published':
        return AppColors.primary;
      default:
        return AppColors.gray500;
    }
  }

  Color _getProductTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'food':
        return AppColors.foodProduct;
      case 'medical':
        return AppColors.medicalProduct;
      case 'other':
        return AppColors.otherProduct;
      default:
        return AppColors.gray500;
    }
  }
}

// Product Card for Selection
class ProductSelectionCard extends StatelessWidget {
  final String productName;
  final String productCode;
  final String productType;
  final bool isSelected;
  final ValueChanged<bool> onSelectionChanged;

  const ProductSelectionCard({
    super.key,
    required this.productName,
    required this.productCode,
    required this.productType,
    required this.isSelected,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.gray300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => onSelectionChanged(!isSelected),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (value) => onSelectionChanged(value ?? false),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: TextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      productCode,
                      style: TextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getProductTypeColor(productType).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _getProductTypeColor(productType),
                    width: 1,
                  ),
                ),
                child: Text(
                  productType.toUpperCase(),
                  style: TextStyles.captionBold.copyWith(
                    color: _getProductTypeColor(productType),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getProductTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'food':
        return AppColors.foodProduct;
      case 'medical':
        return AppColors.medicalProduct;
      case 'other':
        return AppColors.otherProduct;
      default:
        return AppColors.gray500;
    }
  }
}
