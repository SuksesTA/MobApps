import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dst_mk2/services/dekripsi.dart';

class TrackerState {
  // ✅ Singleton instance
  static final TrackerState _instance = TrackerState._internal();
  factory TrackerState() => _instance;
  TrackerState._internal();

  // Informasi tracker
  String? trackerCode;
  String? trackerName;
  String? aesKey;
  AESGCMDecryptor? decryptor;

  // Status koneksi
  bool isConnected = false;

  // Data sensor
  String battery = '-';
  String temperature = '-';
  String humidity = '-';
  String speed = '-';
  String accX = '-';
  String accY = '-';
  String accZ = '-';
  String condition = '-';

  // Lokasi & waktu terakhir update
  LatLng? lastLatLng;
  DateTime? lastUpdateTime;

  // ✅ Reset semua state jika tracker dilepas / logout
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

  // ✅ Untuk keamanan, helper checker
  bool get isReady => isConnected && trackerCode != null && decryptor != null;
}
