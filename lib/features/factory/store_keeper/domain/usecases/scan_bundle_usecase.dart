import 'package:dartz/dartz.dart';
import 'package:nexatrace_system/core/errors/failures.dart';
import 'package:nexatrace_system/core/usecase/usecase.dart';
import 'package:nexatrace_system/features/factory/store_keeper/data/repositories/store_keeper_repository.dart';
import 'package:nexatrace_system/features/factory/store_keeper/domain/entities/scan_record.dart';

class ScanBundleUseCase implements SingleParamUseCase<ScanRecord, String> {
  final StoreKeeperRepository _repository;
  ScanBundleUseCase(this._repository);
  @override
  Future<Either<Failure, ScanRecord>> call(String bundleCode) async {
    try {
      final record = await _repository.scanCode(bundleCode, codeType: 'bundle');
      return Right(record);
    } catch (e, stackTrace) {
      return Left(mapExceptionToFailure(e, stackTrace));
    }
  }
}
