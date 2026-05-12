import 'package:dartz/dartz.dart';
import 'package:nexatrace_system/core/errors/failures.dart';
import 'package:nexatrace_system/core/usecase/usecase.dart';
import 'package:nexatrace_system/features/factory/store_keeper/data/repositories/store_keeper_repository.dart';

class LinkCartonParams {
  final String bundleId;
  final String cartonId;
  const LinkCartonParams({required this.bundleId, required this.cartonId});
}

class LinkCartonUseCase implements UseCase<bool, LinkCartonParams> {
  final StoreKeeperRepository _repository;
  LinkCartonUseCase(this._repository);
  @override
  Future<Either<Failure, bool>> call(LinkCartonParams params) async {
    try {
      final result = await _repository.linkBundleToCarton(
        params.bundleId,
        params.cartonId,
      );
      return Right(result);
    } catch (e, stackTrace) {
      return Left(mapExceptionToFailure(e, stackTrace));
    }
  }
}
