// Non-freezed events — avoids build_runner dependency
import 'bundle_packing_state.dart';

abstract class BundlePackingEvent {
  const BundlePackingEvent();
}

class LoadFormats extends BundlePackingEvent {
  const LoadFormats() : super();
}

class SelectCartonFormat extends BundlePackingEvent {
  final String? format;
  const SelectCartonFormat(this.format) : super();
}

class SelectCartonBatch extends BundlePackingEvent {
  final BatchOption? batch;
  const SelectCartonBatch(this.batch) : super();
}

class ToggleCartonCode extends BundlePackingEvent {
  final String codeId;
  const ToggleCartonCode(this.codeId) : super();
}

class SelectPacketFormat extends BundlePackingEvent {
  final String? format;
  const SelectPacketFormat(this.format) : super();
}

class SelectPacketBatch extends BundlePackingEvent {
  final BatchOption? batch;
  const SelectPacketBatch(this.batch) : super();
}

class TogglePacketCode extends BundlePackingEvent {
  final String codeId;
  const TogglePacketCode(this.codeId) : super();
}

class ResetSelection extends BundlePackingEvent {
  const ResetSelection() : super();
}
