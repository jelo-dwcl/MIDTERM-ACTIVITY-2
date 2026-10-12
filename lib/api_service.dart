import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'models.dart';

class ApiService {
static const String _baseUrl =
'https://commons.wikimedia.org/w/api.php';

static Future<List<CameraPhoto>> fetchCameras() async {
final uri = Uri.https(
'commons.wikimedia.org',
'/w/api.php',
{
'action': 'query',
'generator': 'search',
'gsrsearch': 'filetype:bitmap camera',
'gsrnamespace': '6',
'gsrlimit': '20',
'prop': 'imageinfo',
'iiprop': 'url',
'iiurlwidth': '600',
'inprop': 'url',
'format': 'json',
'origin': '*',
},
);

final response = await http
    .get(
      uri,
      headers: {
        'User-Agent':
            'CameraExplorer/1.0 (Flutter educational project)',
      },
    )
    .timeout(const Duration(seconds: 20));

if (response.statusCode != 200) {
  throw Exception(
    'HTTP error: ${response.statusCode}',
  );
}

final Map<String, dynamic> data =
    jsonDecode(response.body) as Map<String, dynamic>;

if (data.containsKey('error')) {
  final error = data['error'] as Map<String, dynamic>;
  throw Exception(
    error['info'] ?? 'Wikimedia API error',
  );
}

final query = data['query'] as Map<String, dynamic>?;

if (query == null) {
  return [];
}

final pages = query['pages'] as Map<String, dynamic>?;

if (pages == null) {
  return [];
}

final cameras = <CameraPhoto>[];

for (final page in pages.values) {
  if (page is! Map<String, dynamic>) continue;

  try {
    final camera = CameraPhoto.fromJson(page);

    if (camera.imageUrl.isNotEmpty) {
      cameras.add(camera);
    }
  } catch (_) {
    // Skip the files without usable image information.
  }
}

return cameras;

}

static Stream<CameraUpdate> cameraStream() async* {
while (true) {
try {
final cameras = await fetchCameras();
yield CameraUpdate.success(cameras);
} catch (error) {
yield CameraUpdate.failure(
error.toString().replaceFirst('Exception: ', ''),
);
}

  await Future<void>.delayed(
    const Duration(seconds: 5),
  );
}

}
}