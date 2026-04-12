import 'dart:convert';
import 'package:http/http.dart' as http;

/// Result of a geocoding lookup.
class GeocodingResult {
  final double lat;
  final double lng;
  final String displayName;

  const GeocodingResult({
    required this.lat,
    required this.lng,
    required this.displayName,
  });
}

/// Validates that a latitude value is within the valid range [-90, 90].
bool isValidLatitude(double lat) => lat >= -90.0 && lat <= 90.0;

/// Validates that a longitude value is within the valid range [-180, 180].
bool isValidLongitude(double lng) => lng >= -180.0 && lng <= 180.0;

/// Validates that a [GeocodingResult] has coordinates within valid ranges.
bool isValidCoordinates(double lat, double lng) =>
    isValidLatitude(lat) && isValidLongitude(lng);

/// Service for resolving addresses to lat/lng coordinates using the
/// Nominatim OpenStreetMap geocoding API (free, no API key required).
///
/// Requirements 1.2, 4.2: resolve address → lat/lng and store coordinates.
class GeocodingService {
  static const _baseUrl = 'https://nominatim.openstreetmap.org/search';

  /// Resolves [address] to latitude/longitude coordinates.
  ///
  /// Returns a [GeocodingResult] on success, or `null` if the address
  /// could not be resolved (e.g. no results or network error).
  ///
  /// The returned coordinates are guaranteed to satisfy:
  ///   lat ∈ [-90, 90] and lng ∈ [-180, 180]
  static Future<GeocodingResult?> geocodeAddress(String address) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return null;

    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'q': trimmed,
        'format': 'json',
        'limit': '1',
      });

      final response = await http.get(
        uri,
        headers: {
          // Nominatim requires a User-Agent header.
          'User-Agent': 'NGOConnectApp/1.0 (ngo-connect@example.com)',
        },
      );

      if (response.statusCode != 200) return null;

      final List<dynamic> results = jsonDecode(response.body);
      if (results.isEmpty) return null;

      final first = results.first as Map<String, dynamic>;
      final lat = double.tryParse(first['lat'] as String? ?? '');
      final lng = double.tryParse(first['lon'] as String? ?? '');

      if (lat == null || lng == null) return null;
      if (!isValidCoordinates(lat, lng)) return null;

      return GeocodingResult(
        lat: lat,
        lng: lng,
        displayName: first['display_name'] as String? ?? trimmed,
      );
    } catch (_) {
      return null;
    }
  }
}
