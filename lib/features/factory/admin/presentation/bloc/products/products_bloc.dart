import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nexatrace_system/features/factory/admin/data/repositories/factory_products_repository.dart';
import 'package:nexatrace_system/shared/models/product/product_model.dart';

enum ProductsStatus {
  initial,
  loading,
  loaded,
  creating,
  created,
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
  ];
}

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final FactoryProductsRepository _repo;

  ProductsBloc({required FactoryProductsRepository repository})
      : _repo = repository,
        super(const ProductsState()) {
    on<LoadProducts>(_onLoadProducts);
    on<CreateProduct>(_onCreateProduct);
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
      emit(state.copyWith(
        status: ProductsStatus.error,
        errorMessage: e.toString(),
      ));
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
      );

      final updated = [created, ...state.products];
      emit(state.copyWith(status: ProductsStatus.created, products: updated));
      emit(state.copyWith(status: ProductsStatus.loaded, products: updated));
    } catch (e) {
      emit(state.copyWith(
        status: ProductsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}

