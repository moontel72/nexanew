import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:trace_odd/features/factory/admin/data/repositories/factory_products_repository.dart';
import 'package:trace_odd/shared/models/product/product_model.dart';

enum ProductsStatus {
  initial,
  loading,
  loaded,
  creating,
  created,
  updating,
  updated,
  error,
}

class ProductsState extends Equatable {
  final ProductsStatus status;
  final List<ProductModel> products;
  final String? errorMessage;

  const ProductsState({
    this.status = ProductsStatus.initial,
    this.products = const [],
    this.errorMessage,
  });

  ProductsState copyWith({
    ProductsStatus? status,
    List<ProductModel>? products,
    String? errorMessage,
  }) {
    return ProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, products, errorMessage];
}

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductsEvent {
  final String? search;
  const LoadProducts({this.search});

  @override
  List<Object?> get props => [search];
}

class CreateProduct extends ProductsEvent {
  final String name;
  final String sku;
  final String? description;
  final String? category;
  final String productType;
  final bool requiresManufacturingDate;
  final bool requiresExpiryDate;
  final bool requiresWarranty;
  final int? defaultWarrantyMonths;
  final DateTime? defaultManufacturingDate;
  final DateTime? defaultExpiryDate;
  final double? unitPrice;
  final double? cartonPrice;
  final double? wholesalePrice;
  final String? currency;
  final String? discountType;
  final double? discountValue;
  final int? moq;
  final bool? marketplaceEnabled;
  final int? bonusQuantity;
  final int? bonusThreshold;
  final double? walletCredit;
  final String? promoCode;
  final double? promoDiscount;
  final List<String>? tags;
  final List<Map<String, dynamic>>? volumeDiscounts;
  final String? imageUrl;

  const CreateProduct({
    required this.name,
    required this.sku,
    required this.description,
    required this.category,
    required this.productType,
    required this.requiresManufacturingDate,
    required this.requiresExpiryDate,
    required this.requiresWarranty,
    required this.defaultWarrantyMonths,
    required this.defaultManufacturingDate,
    required this.defaultExpiryDate,
    this.unitPrice,
    this.cartonPrice,
    this.wholesalePrice,
    this.currency,
    this.discountType,
    this.discountValue,
    this.moq,
    this.marketplaceEnabled,
    this.bonusQuantity,
    this.bonusThreshold,
    this.walletCredit,
    this.promoCode,
    this.promoDiscount,
    this.tags,
    this.volumeDiscounts,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    name,
    sku,
    description,
    category,
    productType,
    requiresManufacturingDate,
    requiresExpiryDate,
    requiresWarranty,
    defaultWarrantyMonths,
    defaultManufacturingDate,
    defaultExpiryDate,
    unitPrice,
    cartonPrice,
    wholesalePrice,
    currency,
    discountType,
    discountValue,
    moq,
    marketplaceEnabled,
    bonusQuantity,
    bonusThreshold,
    walletCredit,
    promoCode,
    promoDiscount,
    tags,
    volumeDiscounts,
    imageUrl,
  ];
}

final class UpdateProduct extends ProductsEvent {
  final String id;
  final String? name;
  final String? sku;
  final String? description;
  final String? category;
  final String? productType;
  final double? unitPrice;
  final double? cartonPrice;
  final double? wholesalePrice;
  final String? currency;
  final String? discountType;
  final double? discountValue;
  final int? moq;
  final bool? marketplaceEnabled;
  final int? bonusQuantity;
  final int? bonusThreshold;
  final double? walletCredit;
  final String? promoCode;
  final double? promoDiscount;
  final List<String>? tags;
  final List<Map<String, dynamic>>? volumeDiscounts;
  final String? imageUrl;

  UpdateProduct({
    required this.id,
    this.name,
    this.sku,
    this.description,
    this.category,
    this.productType,
    this.unitPrice,
    this.cartonPrice,
    this.wholesalePrice,
    this.currency,
    this.discountType,
    this.discountValue,
    this.moq,
    this.marketplaceEnabled,
    this.bonusQuantity,
    this.bonusThreshold,
    this.walletCredit,
    this.promoCode,
    this.promoDiscount,
    this.tags,
    this.volumeDiscounts,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    sku,
    description,
    category,
    productType,
    unitPrice,
    cartonPrice,
    wholesalePrice,
    currency,
    discountType,
    discountValue,
    moq,
    marketplaceEnabled,
    bonusQuantity,
    bonusThreshold,
    walletCredit,
    promoCode,
    promoDiscount,
    tags,
    volumeDiscounts,
    imageUrl,
  ];
}

final class ToggleMarketplace extends ProductsEvent {
  final String productId;
  final bool enabled;

  ToggleMarketplace({required this.productId, required this.enabled});

  @override
  List<Object?> get props => [productId, enabled];
}

final class DeleteProduct extends ProductsEvent {
  final String id;
  DeleteProduct(this.id);

  @override
  List<Object?> get props => [id];
}

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final FactoryProductsRepository _repo;

  ProductsBloc({required FactoryProductsRepository repository})
    : _repo = repository,
      super(const ProductsState()) {
    on<LoadProducts>(_onLoadProducts);
    on<CreateProduct>(_onCreateProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<ToggleMarketplace>(_onToggleMarketplace);
    on<DeleteProduct>(_onDeleteProduct);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ProductsStatus.loading, errorMessage: null));
      final products = await _repo.listProducts(search: event.search);
      emit(state.copyWith(status: ProductsStatus.loaded, products: products));
    } catch (e) {
      emit(
        state.copyWith(
          status: ProductsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCreateProduct(
    CreateProduct event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ProductsStatus.creating, errorMessage: null));
      final created = await _repo.createProduct(
        name: event.name,
        sku: event.sku,
        description: event.description,
        category: event.category,
        productType: event.productType,
        requiresManufacturingDate: event.requiresManufacturingDate,
        requiresExpiryDate: event.requiresExpiryDate,
        requiresWarranty: event.requiresWarranty,
        defaultWarrantyMonths: event.defaultWarrantyMonths,
        defaultManufacturingDate: event.defaultManufacturingDate,
        defaultExpiryDate: event.defaultExpiryDate,
        unitPrice: event.unitPrice,
        cartonPrice: event.cartonPrice,
        wholesalePrice: event.wholesalePrice,
        currency: event.currency,
        discountType: event.discountType,
        discountValue: event.discountValue,
        moq: event.moq,
        marketplaceEnabled: event.marketplaceEnabled,
        bonusQuantity: event.bonusQuantity,
        bonusThreshold: event.bonusThreshold,
        walletCredit: event.walletCredit,
        promoCode: event.promoCode,
        promoDiscount: event.promoDiscount,
        tags: event.tags,
        volumeDiscounts: event.volumeDiscounts,
        imageUrl: event.imageUrl,
      );

      final updated = [created, ...state.products];
      emit(state.copyWith(status: ProductsStatus.created, products: updated));
      emit(state.copyWith(status: ProductsStatus.loaded, products: updated));
    } catch (e) {
      emit(
        state.copyWith(
          status: ProductsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ProductsStatus.updating, errorMessage: null));
      await _repo.updateProduct(
        id: event.id,
        name: event.name,
        sku: event.sku,
        description: event.description,
        category: event.category,
        productType: event.productType,
        unitPrice: event.unitPrice,
        cartonPrice: event.cartonPrice,
        wholesalePrice: event.wholesalePrice,
        currency: event.currency,
        discountType: event.discountType,
        discountValue: event.discountValue,
        moq: event.moq,
        marketplaceEnabled: event.marketplaceEnabled,
        bonusQuantity: event.bonusQuantity,
        bonusThreshold: event.bonusThreshold,
        walletCredit: event.walletCredit,
        promoCode: event.promoCode,
        promoDiscount: event.promoDiscount,
        tags: event.tags,
        volumeDiscounts: event.volumeDiscounts,
        imageUrl: event.imageUrl,
      );

      // Reload full list after update
      final products = await _repo.listProducts();
      emit(state.copyWith(status: ProductsStatus.updated, products: products));
      emit(state.copyWith(status: ProductsStatus.loaded, products: products));
    } catch (e) {
      emit(
        state.copyWith(
          status: ProductsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onToggleMarketplace(
    ToggleMarketplace event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ProductsStatus.updating, errorMessage: null));
      final updated = await _repo.toggleMarketplace(
        event.productId,
        event.enabled,
      );

      // Update the product in the local list
      final idx = state.products.indexWhere((p) => p.id == event.productId);
      if (idx != -1) {
        final list = List<ProductModel>.from(state.products);
        list[idx] = updated;
        emit(state.copyWith(status: ProductsStatus.updated, products: list));
        emit(state.copyWith(status: ProductsStatus.loaded, products: list));
      } else {
        // Fallback: reload
        final products = await _repo.listProducts();
        emit(
          state.copyWith(status: ProductsStatus.updated, products: products),
        );
        emit(state.copyWith(status: ProductsStatus.loaded, products: products));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ProductsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ProductsStatus.updating, errorMessage: null));
      await _repo.deleteProduct(event.id);

      final list = state.products.where((p) => p.id != event.id).toList();
      emit(state.copyWith(status: ProductsStatus.updated, products: list));
      emit(state.copyWith(status: ProductsStatus.loaded, products: list));
    } catch (e) {
      emit(
        state.copyWith(
          status: ProductsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
