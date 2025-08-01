import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dst_mk2/services/dekripsi.dart';

class TrackerState {
  static final TrackerState _instance = TrackerState._internal();
  factory TrackerState() => _instance;
  TrackerState._internal();

  String? trackerCode;
  String? trackerName;
  String? aesKey;
  AESGCMDecryptor? decryptor;
  bool isConnected = false;

  String battery = '-';
  String temperature = '-';
  String humidity = '-';
  String speed = '-';
  String accX = '-';
  String accY = '-';
  String accZ = '-';
  String condition = '-';

  LatLng? lastLatLng;
  DateTime? lastUpdateTime;

  void reset() {
    trackerCode = null;
    trackerName = null;
    aesKey = null;
    decryptor = null;
    isConnected = false;

    battery = '-';
    temperature = '-';
    humidity = '-';
    speed = '-';
    accX = '-';
    accY = '-';
    accZ = '-';
    condition = '-';
    lastLatLng = null;
    lastUpdateTime = null;
  }
}
