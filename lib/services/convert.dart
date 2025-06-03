import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationData {
  final LatLng latLng;
  final double temperature;
  final double humidity;

  LocationData(this.latLng, this.temperature, this.humidity);
}

class Konversi {
  LocationData convertStringToLocationData(String data) {
    List<String> parts = data.split(',');

    if (parts.length != 4) {
      throw const FormatException("Input string harus berisi 4 value");
    }

    double longitude = double.tryParse(parts[0].trim()) ?? 0.0;
    double latitude = double.tryParse(parts[1].trim()) ?? 0.0;
    double temperature = double.tryParse(parts[2].trim()) ?? 0.0;
    double humidity = double.tryParse(parts[3].trim()) ?? 0.0;

    LatLng latLng = LatLng(latitude, longitude);

    return LocationData(latLng, temperature, humidity);
  }
}
