import 'package:dartz/dartz.dart';
import 'package:nexatrace_system/core/errors/failures.dart';
import 'package:nexatrace_system/core/usecase/usecase.dart';
import 'package:nexatrace_system/features/factory/store_keeper/data/repositories/store_keeper_repository.dart';

class LinkUnitsParams {
  final String packetId;
  final String unitId;
  final String productId;
  final int quantity;
  const LinkUnitsParams({
    required this.packetId,
    required this.unitId,
    required this.productId,
    required this.quantity,
  });
}

class LinkUnitsUseCase implements UseCase<bool, LinkUnitsParams> {
  final StoreKeeperRepository _repository;
  LinkUnitsUseCase(this._repository);
  @override
  Future<Either<Failure, bool>> call(LinkUnitsParams params) async {
    try {
      final result = await _repository.linkUnitToPacket(
        params.packetId,
        params.unitId,
        params.productId,
        params.quantity,
      );
      return Right(result);
    } catch (e, stackTrace) {
      return Left(mapExceptionToFailure(e, stackTrace));
    }
  }
}
