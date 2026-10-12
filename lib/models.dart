class CameraPhoto { final String title; final String imageUrl; final String pageUrl;

const CameraPhoto({ required this.title, required this.imageUrl, required this.pageUrl, });

factory CameraPhoto.fromJson(Map<String, dynamic> json) { final imageInfoList = json['imageinfo'] as List?;

if (imageInfoList == null || imageInfoList.isEmpty) {
  throw const FormatException('Missing image information');
}

final imageInfo =
    imageInfoList.first as Map<String, dynamic>;

return CameraPhoto(
  title: json['title'] as String? ?? 'Camera image',
  imageUrl: imageInfo['thumburl'] as String? ??
      imageInfo['url'] as String? ??
      '',
  pageUrl: json['fullurl'] as String? ?? '',
);
} }

class CameraUpdate { final List? cameras; final String? error;

const CameraUpdate._({ this.cameras, this.error, });

factory CameraUpdate.success(List cameras) { return CameraUpdate._(cameras: cameras); }

factory CameraUpdate.failure(String error) { return CameraUpdate._(error: error); }

bool get hasError => error != null; }