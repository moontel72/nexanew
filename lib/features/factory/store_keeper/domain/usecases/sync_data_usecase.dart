import 'package:dartz/dartz.dart';
import 'package:nexatrace_system/core/errors/failures.dart';
import 'package:nexatrace_system/core/usecase/usecase.dart';
import 'package:nexatrace_system/features/factory/store_keeper/data/repositories/store_keeper_repository.dart';
import 'package:nexatrace_system/features/factory/store_keeper/domain/entities/scan_record.dart';

class SyncDataUseCase implements NoParamsUseCase<SyncResult> {
  final StoreKeeperRepository _repository;
  SyncDataUseCase(this._repository);
  @override
  Future<Either<Failure, SyncResult>> call() async {
    try {
      final result = await _repository.syncAll();
      return Right(result);
    } catch (e, stackTrace) {
      return Left(mapExceptionToFailure(e, stackTrace));
    }
  }
}

class SyncResult {
  final int syncedCount;
  final int failedCount;
  final int conflictCount;
  final List<ScanRecord> syncedRecords;
  final List<String> errors;
  const SyncResult({
    required this.syncedCount,
    required this.failedCount,
    required this.conflictCount,
    required this.syncedRecords,
    required this.errors,
  });
  bool get isFullySuccessful => failedCount == 0 && conflictCount == 0;
}
