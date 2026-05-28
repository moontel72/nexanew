import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:trace_odd/shared/models/transport/goods_company_model.dart';

part 'goods_company_auth_event.dart';
part 'goods_company_auth_state.dart';

class GoodsCompanyAuthBloc
    extends Bloc<GoodsCompanyAuthEvent, GoodsCompanyAuthState> {
  GoodsCompanyAuthBloc() : super(const GoodsCompanyAuthInitial()) {
    on<RegisterGoodsCompany>(_onRegister);
    on<LoginGoodsCompany>(_onLogin);
    on<LoginWithOtp>(_onLoginWithOtp);
    on<VerifyGoodsCompany>(_onVerify);
    on<SubmitVerificationDocuments>(_onSubmitDocuments);
    on<LogoutGoodsCompany>(_onLogout);
    on<UpdateGoodsCompanyProfile>(_onUpdateProfile);
    on<ChangeGoodsCompanyPassword>(_onChangePassword);
  }

  Future<void> _onRegister(
      RegisterGoodsCompany event, Emitter<GoodsCompanyAuthState> emit) async {
    emit(const GoodsCompanyAuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(const GoodsCompanyAuthSuccess(message: 'Registration successful'));
  }

  Future<void> _onLogin(
      LoginGoodsCompany event, Emitter<GoodsCompanyAuthState> emit) async {
    emit(const GoodsCompanyAuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(const GoodsCompanyAuthAuthenticated(
        company: null)); // In reality, pass the company data
  }

  Future<void> _onLoginWithOtp(
      LoginWithOtp event, Emitter<GoodsCompanyAuthState> emit) async {
    emit(const GoodsCompanyAuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(const GoodsCompanyAuthAuthenticated(company: null));
  }

  Future<void> _onVerify(
      VerifyGoodsCompany event, Emitter<GoodsCompanyAuthState> emit) async {
    emit(const GoodsCompanyAuthLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(const GoodsCompanyAuthSuccess(message: 'Verification status updated'));
  }

  Future<void> _onSubmitDocuments(SubmitVerificationDocuments event,
      Emitter<GoodsCompanyAuthState> emit) async {
    emit(const GoodsCompanyAuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(const GoodsCompanyAuthSuccess(
        message: 'Documents submitted successfully'));
  }

  Future<void> _onLogout(
      LogoutGoodsCompany event, Emitter<GoodsCompanyAuthState> emit) async {
    emit(const GoodsCompanyAuthUnauthenticated());
  }

  Future<void> _onUpdateProfile(UpdateGoodsCompanyProfile event,
      Emitter<GoodsCompanyAuthState> emit) async {
    emit(const GoodsCompanyAuthLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(
        const GoodsCompanyAuthSuccess(message: 'Profile updated successfully'));
  }

  Future<void> _onChangePassword(ChangeGoodsCompanyPassword event,
      Emitter<GoodsCompanyAuthState> emit) async {
    emit(const GoodsCompanyAuthLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(const GoodsCompanyAuthSuccess(
        message: 'Password changed successfully'));
  }
}
