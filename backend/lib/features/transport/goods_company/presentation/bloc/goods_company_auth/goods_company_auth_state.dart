part of 'goods_company_auth_bloc.dart';

abstract class GoodsCompanyAuthState extends Equatable {
  const GoodsCompanyAuthState();

  @override
  List<Object?> get props => [];
}

class GoodsCompanyAuthInitial extends GoodsCompanyAuthState {
  const GoodsCompanyAuthInitial();
}

class GoodsCompanyAuthLoading extends GoodsCompanyAuthState {
  const GoodsCompanyAuthLoading();
}

class GoodsCompanyAuthAuthenticated extends GoodsCompanyAuthState {
  final dynamic company; // Use actual company model here

  const GoodsCompanyAuthAuthenticated({this.company});

  @override
  List<Object?> get props => [company];
}

class GoodsCompanyAuthUnauthenticated extends GoodsCompanyAuthState {
  const GoodsCompanyAuthUnauthenticated();
}

class GoodsCompanyAuthSuccess extends GoodsCompanyAuthState {
  final String message;

  const GoodsCompanyAuthSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class GoodsCompanyAuthError extends GoodsCompanyAuthState {
  final String message;

  const GoodsCompanyAuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
