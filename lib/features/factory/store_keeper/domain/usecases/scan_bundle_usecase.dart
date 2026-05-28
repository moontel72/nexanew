import 'package:dartz/dartz.dart';
import 'package:trace_odd/core/errors/failures.dart';
import 'package:trace_odd/core/usecase/usecase.dart';
import 'package:trace_odd/features/factory/store_keeper/data/repositories/store_keeper_repository.dart';
import 'package:trace_odd/features/factory/store_keeper/domain/entities/scan_record.dart';

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
