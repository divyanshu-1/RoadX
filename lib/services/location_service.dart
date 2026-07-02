import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// GPS + reverse geocoding for challan map pin.
class LocationService {
  Future<({double lat, double lng, String address})> getCurrentLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('Location services are disabled');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    String address = '${position.latitude.toStringAsFixed(5)}, '
        '${position.longitude.toStringAsFixed(5)}';
    try {
      final places = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (places.isNotEmpty) {
        final p = places.first;
        address = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
        ].where((e) => e != null && e!.isNotEmpty).map((e) => e!).join(', ');
      }
    } catch (_) {}

    return (
      lat: position.latitude,
      lng: position.longitude,
      address: address,
    );
  }
}
