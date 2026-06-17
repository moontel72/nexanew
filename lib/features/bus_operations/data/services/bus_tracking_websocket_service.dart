// NEXATRACE — BUS TRACKING WEBSOCKET SERVICE (STUB)
// ====================================================
// Platform-conditional export: uses dart:html on web,
// dart:io on native. Import this file in your code and
// use BusTrackingWebsocketService directly.
//
// MODULE: 8V — Live Bus Tracking Canvas

export 'bus_tracking_websocket_web.dart'
    if (dart.library.io) 'bus_tracking_websocket_io.dart';
export 'bus_tracking_models.dart';
