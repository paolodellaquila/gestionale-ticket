import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Token da file `.env` (consigliato) oppure `--dart-define=MAPBOX_ACCESS_TOKEN=...`
class MapboxConfig {
  static String get accessToken {
    final fromFile = dotenv.env['MAPBOX_ACCESS_TOKEN']?.trim() ?? '';
    if (fromFile.isNotEmpty) return fromFile;
    return const String.fromEnvironment(
      'MAPBOX_ACCESS_TOKEN',
      defaultValue: '',
    );
  }

  static String get styleId {
    final fromFile = dotenv.env['MAPBOX_STYLE_ID']?.trim() ?? '';
    if (fromFile.isNotEmpty) return fromFile;
    return const String.fromEnvironment(
      'MAPBOX_STYLE_ID',
      defaultValue: 'mapbox/streets-v12',
    );
  }

  static bool get isConfigured => accessToken.isNotEmpty;

  /// Tile raster Mapbox (256px) per [flutter_map] su Web.
  static String get tileUrlTemplate =>
      'https://api.mapbox.com/styles/v1/$styleId/tiles/256/{z}/{x}/{y}@2x'
      '?access_token=$accessToken';
}
