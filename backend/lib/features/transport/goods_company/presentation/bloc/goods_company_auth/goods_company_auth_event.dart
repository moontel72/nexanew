part of 'goods_company_auth_bloc.dart';

abstract class GoodsCompanyAuthEvent extends Equatable {
  const GoodsCompanyAuthEvent();

  @override
  List<Object> get props => [];
}

// Registration events
class RegisterGoodsCompany extends GoodsCompanyAuthEvent {
  final String companyName;
  final String ownerName;
  final String phone;
  final String email;
  final String cnic;
  final String address;
  final GoodsCompanyPlanType planType;
  final double? initialBalance;

  const RegisterGoodsCompany({
    required this.companyName,
    required this.ownerName,
    required this.phone,
    required this.email,
    required this.cnic,
    required this.address,
    required this.planType,
    this.initialBalance,
  });

  @override
  List<Object> get props => [
        companyName,
        ownerName,
        phone,
        email,
        cnic,
        address,
        planType,
        initialBalance ?? 0.0,
      ];
}

// Login events
class LoginGoodsCompany extends GoodsCompanyAuthEvent {
  final String phone;
  final String password;

  const LoginGoodsCompany({
    required this.phone,
    required this.password,
  });

  @override
  List<Object> get props => [phone, password];
}

class LoginWithOtp extends GoodsCompanyAuthEvent {
  final String phone;
  final String otp;

  const LoginWithOtp({
    required this.phone,
    required this.otp,
  });

  @override
  List<Object> get props => [phone, otp];
}

// Verification events
class VerifyGoodsCompany extends GoodsCompanyAuthEvent {
  final String companyId;
  final VerificationStatus status;
  final String? notes;

  const VerifyGoodsCompany({
    required this.companyId,
    required this.status,
    this.notes,
  });

  @override
  List<Object> get props => [companyId, status, notes ?? ''];
}

class SubmitVerificationDocuments extends GoodsCompanyAuthEvent {
  final String companyId;
  final Map<String, String> documents; // document_type -> file_url
  final String? notes;

  const SubmitVerificationDocuments({
    required this.companyId,
    required this.documents,
    this.notes,
  });

  @override
  List<Object> get props => [companyId, documents, notes ?? ''];
}

// Profile management events
class UpdateGoodsCompanyProfile extends GoodsCompanyAuthEvent {
  final String companyId;
  final Map<String, dynamic> updates;

  const UpdateGoodsCompanyProfile({
    required this.companyId,
    required this.updates,
  });

  @override
  List<Object> get props => [companyId, updates];
}

class ChangeGoodsCompanyPassword extends GoodsCompanyAuthEvent {
  final String companyId;
  final String currentPassword;
  final String newPassword;

  const ChangeGoodsCompanyPassword({
    required this.companyId,
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [companyId, currentPassword, newPassword];
}

class UpdateGoodsCompanySettings extends GoodsCompanyAuthEvent {
  final String companyId;
  final Map<String, dynamic> settingsUpdates;

  const UpdateGoodsCompanySettings({
    required this.companyId,
    required this.settingsUpdates,
  });

  @override
  List<Object> get props => [companyId, settingsUpdates];
}

// Subscription events
class UpgradeGoodsCompanyPlan extends GoodsCompanyAuthEvent {
  final String companyId;
  final GoodsCompanyPlanType newPlanType;
  final String paymentMethod;
  final String paymentReference;

  const UpgradeGoodsCompanyPlan({
    required this.companyId,
    required this.newPlanType,
    required this.paymentMethod,
    required this.paymentReference,
  });

  @override
  List<Object> get props => [
        companyId,
        newPlanType,
        paymentMethod,
        paymentReference,
      ];
}

class RenewSubscription extends GoodsCompanyAuthEvent {
  final String subscriptionId;
  final String paymentReference;

  const RenewSubscription({
    required this.subscriptionId,
    required this.paymentReference,
  });

  @override
  List<Object> get props => [subscriptionId, paymentReference];
}

class CancelSubscription extends GoodsCompanyAuthEvent {
  final String subscriptionId;
  final String reason;

  const CancelSubscription({
    required this.subscriptionId,
    required this.reason,
  });

  @override
  List<Object> get props => [subscriptionId, reason];
}

// Wallet and payment events
class CheckWalletBalance extends GoodsCompanyAuthEvent {
  final String companyId;

  const CheckWalletBalance(this.companyId);

  @override
  List<Object> get props => [companyId];
}

class TopUpWallet extends GoodsCompanyAuthEvent {
  final String companyId;
  final double amount;
  final String paymentMethod;

  const TopUpWallet({
    required this.companyId,
    required this.amount,
    required this.paymentMethod,
  });

  @override
  List<Object> get props => [companyId, amount, paymentMethod];
}

class WithdrawFunds extends GoodsCompanyAuthEvent {
  final String companyId;
  final double amount;
  final String bankAccountId;

  const WithdrawFunds({
    required this.companyId,
    required this.amount,
    required this.bankAccountId,
  });

  @override
  List<Object> get props => [companyId, amount, bankAccountId];
}

// Commission management events
class UpdateCommissionStructure extends GoodsCompanyAuthEvent {
  final String companyId;
  final double minPercentage;
  final double maxPercentage;
  final bool isDynamic;
  final Map<String, double>? dynamicRates;
  final bool includeTax;
  final bool includeInsurance;
  final String? notes;

  const UpdateCommissionStructure({
    required this.companyId,
    required this.minPercentage,
    required this.maxPercentage,
    this.isDynamic = true,
    this.dynamicRates,
    this.includeTax = false,
    this.includeInsurance = false,
    this.notes,
  });

  @override
  List<Object> get props => [
        companyId,
        minPercentage,
        maxPercentage,
        isDynamic,
        dynamicRates ?? {},
        includeTax,
        includeInsurance,
        notes ?? '',
      ];
}

// Security events
class ChangePassword extends GoodsCompanyAuthEvent {
  final String companyId;
  final String currentPassword;
  final String newPassword;

  const ChangePassword({
    required this.companyId,
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [companyId, currentPassword, newPassword];
}

class ResetPassword extends GoodsCompanyAuthEvent {
  final String phone;
  final String otp;
  final String newPassword;

  const ResetPassword({
    required this.phone,
    required this.otp,
    required this.newPassword,
  });

  @override
  List<Object> get props => [phone, otp, newPassword];
}

class RequestPasswordReset extends GoodsCompanyAuthEvent {
  final String phone;

  const RequestPasswordReset(this.phone);

  @override
  List<Object> get props => [phone];
}

// Session management events
class CheckAuthStatus extends GoodsCompanyAuthEvent {
  final String companyId;

  const CheckAuthStatus(this.companyId);

  @override
  List<Object> get props => [companyId];
}

class RefreshAuthToken extends GoodsCompanyAuthEvent {
  final String refreshToken;

  const RefreshAuthToken(this.refreshToken);

  @override
  List<Object> get props => [refreshToken];
}

class LogoutGoodsCompany extends GoodsCompanyAuthEvent {
  final String companyId;

  const LogoutGoodsCompany(this.companyId);

  @override
  List<Object> get props => [companyId];
}

// Validation events
class ValidateCompanyRegistration extends GoodsCompanyAuthEvent {
  final String phone;
  final String cnic;
  final String email;

  const ValidateCompanyRegistration({
    required this.phone,
    required this.cnic,
    required this.email,
  });

  @override
  List<Object> get props => [phone, cnic, email];
}

class CheckPhoneAvailability extends GoodsCompanyAuthEvent {
  final String phone;

  const CheckPhoneAvailability(this.phone);

  @override
  List<Object> get props => [phone];
}

class CheckCnicAvailability extends GoodsCompanyAuthEvent {
  final String cnic;

  const CheckCnicAvailability(this.cnic);

  @override
  List<Object> get props => [cnic];
}

// Support events
class RequestSupport extends GoodsCompanyAuthEvent {
  final String companyId;
  final String subject;
  final String message;
  final List<String>? attachments;
  final String priority;

  const RequestSupport({
    required this.companyId,
    required this.subject,
    required this.message,
    this.attachments,
    this.priority = 'medium',
  });

  @override
  List<Object> get props => [
        companyId,
        subject,
        message,
        attachments ?? [],
        priority,
      ];
}

// Clear events
class ClearAuthError extends GoodsCompanyAuthEvent {}

class ClearAuthData extends GoodsCompanyAuthEvent {}

// OTP events
class SendOtp extends GoodsCompanyAuthEvent {
  final String phone;
  final String purpose; // login, registration, reset_password

  const SendOtp({
    required this.phone,
    required this.purpose,
  });

  @override
  List<Object> get props => [phone, purpose];
}

class VerifyOtp extends GoodsCompanyAuthEvent {
  final String phone;
  final String otp;
  final String purpose;

  const VerifyOtp({
    required this.phone,
    required this.otp,
    required this.purpose,
  });

  @override
  List<Object> get props => [phone, otp, purpose];
}

// Document upload events
class UploadCompanyDocument extends GoodsCompanyAuthEvent {
  final String companyId;
  final String documentType;
  final String filePath;
  final String? description;

  const UploadCompanyDocument({
    required this.companyId,
    required this.documentType,
    required this.filePath,
    this.description,
  });

  @override
  List<Object> get props =>
      [companyId, documentType, filePath, description ?? ''];
}

class GetCompanyDocuments extends GoodsCompanyAuthEvent {
  final String companyId;
  final String? documentType;

  const GetCompanyDocuments({
    required this.companyId,
    this.documentType,
  });

  @override
  List<Object> get props => [companyId, documentType ?? ''];
}

// Bank account events
class AddBankAccount extends GoodsCompanyAuthEvent {
  final String companyId;
  final String accountNumber;
  final String bankName;
  final String accountHolderName;
  final String? iban;
  final String? branchCode;

  const AddBankAccount({
    required this.companyId,
    required this.accountNumber,
    required this.bankName,
    required this.accountHolderName,
    this.iban,
    this.branchCode,
  });

  @override
  List<Object> get props => [
        companyId,
        accountNumber,
        bankName,
        accountHolderName,
        iban ?? '',
        branchCode ?? '',
      ];
}

class UpdateBankAccount extends GoodsCompanyAuthEvent {
  final String companyId;
  final String accountId;
  final Map<String, dynamic> updates;

  const UpdateBankAccount({
    required this.companyId,
    required this.accountId,
    required this.updates,
  });

  @override
  List<Object> get props => [companyId, accountId, updates];
}

class RemoveBankAccount extends GoodsCompanyAuthEvent {
  final String companyId;
  final String accountId;
  final String reason;

  const RemoveBankAccount({
    required this.companyId,
    required this.accountId,
    required this.reason,
  });

  @override
  List<Object> get props => [companyId, accountId, reason];
}

// Tax information events
class UpdateTaxInformation extends GoodsCompanyAuthEvent {
  final String companyId;
  final String taxNumber;
  final String taxType;
  final DateTime? registrationDate;
  final String? certificateUrl;

  const UpdateTaxInformation({
    required this.companyId,
    required this.taxNumber,
    required this.taxType,
    this.registrationDate,
    this.certificateUrl,
  });

  @override
  List<Object> get props => [
        companyId,
        taxNumber,
        taxType,
        registrationDate ?? DateTime.now(),
        certificateUrl ?? '',
      ];
}

// Refresh events
class RefreshCompanyData extends GoodsCompanyAuthEvent {
  final String companyId;

  const RefreshCompanyData(this.companyId);

  @override
  List<Object> get props => [companyId];
}
