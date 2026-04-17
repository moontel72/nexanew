// File: lib/core/usecase/usecase.dart

import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Abstract class for Use Cases (Interactors in Clean Architecture)
/// [Type] is the return type of the use case
/// [Params] is the parameters required by the use case
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case with no parameters
abstract class NoParamsUseCase<Type> {
  Future<Either<Failure, Type>> call();
}

/// Use case with single parameter
abstract class SingleParamUseCase<Type, Param> {
  Future<Either<Failure, Type>> call(Param param);
}

/// Use case with multiple parameters
abstract class MultiParamUseCase<Type, Param1, Param2> {
  Future<Either<Failure, Type>> call(Param1 param1, Param2 param2);
}

/// Use case with three parameters
abstract class ThreeParamUseCase<Type, Param1, Param2, Param3> {
  Future<Either<Failure, Type>> call(
      Param1 param1, Param2 param2, Param3 param3);
}

/// Use case with four parameters
abstract class FourParamUseCase<Type, Param1, Param2, Param3, Param4> {
  Future<Either<Failure, Type>> call(
      Param1 param1, Param2 param2, Param3 param3, Param4 param4);
}

/// Concrete implementation of UseCase with parameters
class ConcreteUseCase<Type, Params> implements UseCase<Type, Params> {
  final Future<Either<Failure, Type>> Function(Params params) _function;

  const ConcreteUseCase(this._function);

  @override
  Future<Either<Failure, Type>> call(Params params) => _function(params);
}

/// Concrete implementation of UseCase without parameters
class ConcreteNoParamsUseCase<Type> implements NoParamsUseCase<Type> {
  final Future<Either<Failure, Type>> Function() _function;

  const ConcreteNoParamsUseCase(this._function);

  @override
  Future<Either<Failure, Type>> call() => _function();
}

/// Concrete implementation of UseCase with single parameter
class ConcreteSingleParamUseCase<Type, Param>
    implements SingleParamUseCase<Type, Param> {
  final Future<Either<Failure, Type>> Function(Param param) _function;

  const ConcreteSingleParamUseCase(this._function);

  @override
  Future<Either<Failure, Type>> call(Param param) => _function(param);
}

/// Concrete implementation of UseCase with two parameters
class ConcreteMultiParamUseCase<Type, Param1, Param2>
    implements MultiParamUseCase<Type, Param1, Param2> {
  final Future<Either<Failure, Type>> Function(Param1 param1, Param2 param2)
      _function;

  const ConcreteMultiParamUseCase(this._function);

  @override
  Future<Either<Failure, Type>> call(Param1 param1, Param2 param2) =>
      _function(param1, param2);
}

/// Concrete implementation of UseCase with three parameters
class ConcreteThreeParamUseCase<Type, Param1, Param2, Param3>
    implements ThreeParamUseCase<Type, Param1, Param2, Param3> {
  final Future<Either<Failure, Type>> Function(
      Param1 param1, Param2 param2, Param3 param3) _function;

  const ConcreteThreeParamUseCase(this._function);

  @override
  Future<Either<Failure, Type>> call(
          Param1 param1, Param2 param2, Param3 param3) =>
      _function(param1, param2, param3);
}

/// Concrete implementation of UseCase with four parameters
class ConcreteFourParamUseCase<Type, Param1, Param2, Param3, Param4>
    implements FourParamUseCase<Type, Param1, Param2, Param3, Param4> {
  final Future<Either<Failure, Type>> Function(
      Param1 param1, Param2 param2, Param3 param3, Param4 param4) _function;

  const ConcreteFourParamUseCase(this._function);

  @override
  Future<Either<Failure, Type>> call(
          Param1 param1, Param2 param2, Param3 param3, Param4 param4) =>
      _function(param1, param2, param3, param4);
}

/// Helper class for creating use cases
class UseCaseFactory {
  /// Create a use case with parameters
  static UseCase<Type, Params> create<Type, Params>(
    Future<Either<Failure, Type>> Function(Params params) function,
  ) {
    return ConcreteUseCase<Type, Params>(function);
  }

  /// Create a use case without parameters
  static NoParamsUseCase<Type> createNoParams<Type>(
    Future<Either<Failure, Type>> Function() function,
  ) {
    return ConcreteNoParamsUseCase<Type>(function);
  }

  /// Create a use case with single parameter
  static SingleParamUseCase<Type, Param> createSingleParam<Type, Param>(
    Future<Either<Failure, Type>> Function(Param param) function,
  ) {
    return ConcreteSingleParamUseCase<Type, Param>(function);
  }

  /// Create a use case with two parameters
  static MultiParamUseCase<Type, Param1, Param2>
      createMultiParam<Type, Param1, Param2>(
    Future<Either<Failure, Type>> Function(Param1 param1, Param2 param2)
        function,
  ) {
    return ConcreteMultiParamUseCase<Type, Param1, Param2>(function);
  }

  /// Create a use case with three parameters
  static ThreeParamUseCase<Type, Param1, Param2, Param3>
      createThreeParam<Type, Param1, Param2, Param3>(
    Future<Either<Failure, Type>> Function(
            Param1 param1, Param2 param2, Param3 param3)
        function,
  ) {
    return ConcreteThreeParamUseCase<Type, Param1, Param2, Param3>(function);
  }

  /// Create a use case with four parameters
  static FourParamUseCase<Type, Param1, Param2, Param3, Param4>
      createFourParam<Type, Param1, Param2, Param3, Param4>(
    Future<Either<Failure, Type>> Function(
            Param1 param1, Param2 param2, Param3 param3, Param4 param4)
        function,
  ) {
    return ConcreteFourParamUseCase<Type, Param1, Param2, Param3, Param4>(
        function);
  }
}

/// Parameters for use cases that require no parameters
class NoParams {
  const NoParams();
}

/// Parameters for use cases that require pagination
class PaginationParams {
  final int page;
  final int perPage;
  final String? search;
  final String? sortBy;
  final String? sortOrder;

  const PaginationParams({
    this.page = 1,
    this.perPage = 20,
    this.search,
    this.sortBy = 'created_at',
    this.sortOrder = 'desc',
  });

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'per_page': perPage,
      'search': search,
      'sort_by': sortBy,
      'sort_order': sortOrder,
    };
  }
}

/// Parameters for use cases that require filtering
class FilterParams {
  final Map<String, dynamic> filters;
  final PaginationParams pagination;

  const FilterParams({
    required this.filters,
    this.pagination = const PaginationParams(),
  });

  Map<String, dynamic> toJson() {
    return {
      'filters': filters,
      ...pagination.toJson(),
    };
  }
}

/// Parameters for use cases that require date range
class DateRangeParams {
  final DateTime startDate;
  final DateTime endDate;
  final PaginationParams pagination;

  const DateRangeParams({
    required this.startDate,
    required this.endDate,
    this.pagination = const PaginationParams(),
  });

  Map<String, dynamic> toJson() {
    return {
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      ...pagination.toJson(),
    };
  }
}

/// Parameters for use cases that require ID
class IdParams {
  final String id;

  const IdParams(this.id);

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

/// Parameters for use cases that require multiple IDs
class IdsParams {
  final List<String> ids;

  const IdsParams(this.ids);

  Map<String, dynamic> toJson() {
    return {'ids': ids};
  }
}

/// Parameters for use cases that require email
class EmailParams {
  final String email;

  const EmailParams(this.email);

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

/// Parameters for use cases that require token
class TokenParams {
  final String token;

  const TokenParams(this.token);

  Map<String, dynamic> toJson() {
    return {'token': token};
  }
}

/// Parameters for use cases that require credentials
class CredentialsParams {
  final String email;
  final String password;
  final bool rememberMe;

  const CredentialsParams({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'remember_me': rememberMe,
    };
  }
}

/// Parameters for use cases that require password change
class PasswordChangeParams {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const PasswordChangeParams({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    };
  }
}

/// Parameters for use cases that require password reset
class PasswordResetParams {
  final String email;
  final String token;
  final String newPassword;
  final String confirmPassword;

  const PasswordResetParams({
    required this.email,
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'token': token,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    };
  }
}

/// Parameters for use cases that require file upload
class FileUploadParams {
  final String filePath;
  final String fileName;
  final String? fileType;
  final Map<String, dynamic>? metadata;

  const FileUploadParams({
    required this.filePath,
    required this.fileName,
    this.fileType,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'file_path': filePath,
      'file_name': fileName,
      'file_type': fileType,
      'metadata': metadata,
    };
  }
}
