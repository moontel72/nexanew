import 'package:dartz/dartz.dart';
import 'package:nexatrace_system/core/errors/failures.dart';
import 'package:nexatrace_system/core/usecase/usecase.dart';
import 'package:nexatrace_system/features/factory/store_keeper/data/repositories/store_keeper_repository.dart';

class LinkPacketParams {
  final String cartonId;
  final String packetId;
  const LinkPacketParams({required this.cartonId, required this.packetId});
}

class LinkPacketUseCase implements UseCase<bool, LinkPacketParams> {
  final StoreKeeperRepository _repository;
  LinkPacketUseCase(this._repository);
  @override
  Future<Either<Failure, bool>> call(LinkPacketParams params) async {
    try {
      final result = await _repository.linkCartonToPacket(
        params.cartonId,
        params.packetId,
      );
      return Right(result);
    } catch (e, stackTrace) {
      return Left(mapExceptionToFailure(e, stackTrace));
    }
  }
}
