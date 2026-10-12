import 'package:flutter/material.dart';

import 'api_service.dart';
import 'models.dart';

class OrderScreen extends StatefulWidget {
const OrderScreen({super.key});

@override
State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
late Future<List<CameraPhoto>> camerasFuture;

@override
void initState() {
super.initState();
camerasFuture = ApiService.fetchCameras();
}

void retry() {
setState(() {
camerasFuture = ApiService.fetchCameras();
});
}

@override
Widget build(BuildContext context) {
return FutureBuilder<List<CameraPhoto>>(
future: camerasFuture,
builder: (context, snapshot) {
if (snapshot.connectionState == ConnectionState.waiting) {
return const Center(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
CircularProgressIndicator(),
SizedBox(height: 16),
Text('Loading camera images...'),
],
),
);
}

    if (snapshot.hasError) {
      return _MessageView(
        icon: Icons.wifi_off,
        message: 'Could not load camera images.\n'
            '${snapshot.error}',
        buttonText: 'Retry',
        onPressed: retry,
      );
    }

    final cameras = snapshot.data ?? [];

    if (cameras.isEmpty) {
      return _MessageView(
        icon: Icons.photo_camera_outlined,
        message: 'No camera images found.',
        buttonText: 'Try Again',
        onPressed: retry,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => retry(),
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: cameras.length,
        itemBuilder: (context, index) {
          final camera = cameras[index];

          return Card(
            clipBehavior: Clip.antiAlias,
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  camera.imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;

                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        camera.title.replaceFirst('File:', ''),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Image source: Wikimedia Commons',
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 13,
                        ),
                      ),
                      if (camera.pageUrl.isNotEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () {
                              _showSourceInfo(context, camera);
                            },
                            icon: const Icon(
                              Icons.info_outline,
                            ),
                            label: const Text(
                              'Source and license',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  },
);

}
}

class BeltScreen extends StatefulWidget {
const BeltScreen({super.key});

@override
State<BeltScreen> createState() => _BeltScreenState();
}

class _BeltScreenState extends State<BeltScreen> {
late final Stream<CameraUpdate> cameraUpdates;

@override
void initState() {
super.initState();
cameraUpdates = ApiService.cameraStream();
}

@override
Widget build(BuildContext context) {
return StreamBuilder<CameraUpdate>(
stream: cameraUpdates,
builder: (context, snapshot) {
if (snapshot.connectionState == ConnectionState.waiting &&
!snapshot.hasData) {
return const Center(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
CircularProgressIndicator(),
SizedBox(height: 12),
Text('Waiting for the first camera update...'),
],
),
);
}

    if (snapshot.hasError) {
      return Center(
        child: Text('Stream error: ${snapshot.error}'),
      );
    }

    if (!snapshot.hasData) {
      return const Center(
        child: Text('Waiting for camera data...'),
      );
    }

    final update = snapshot.data!;

    if (update.hasError) {
      return _MessageView(
        icon: Icons.wifi_off,
        message: 'Camera update failed:\n${update.error}\n\n'
            'The app will try again in 5 seconds.',
      );
    }

    final cameras = update.cameras ?? [];

    if (cameras.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No camera images found.\n'
            'The next update will arrive in 5 seconds.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sync,
                color: Colors.blue,
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Camera images refresh every 5 seconds',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: cameras.length,
            itemBuilder: (context, index) {
              final camera = cameras[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      camera.imageUrl,
                      width: 82,
                      height: 82,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          width: 82,
                          height: 82,
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    camera.title.replaceFirst('File:', ''),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'Wikimedia Commons image',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  trailing: IconButton(
                    tooltip: 'Source and license',
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      _showSourceInfo(context, camera);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  },
);

}
}

class _MessageView extends StatelessWidget {
final IconData icon;
final String message;
final String? buttonText;
final VoidCallback? onPressed;

const _MessageView({
required this.icon,
required this.message,
this.buttonText,
this.onPressed,
});

@override
Widget build(BuildContext context) {
return Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
icon,
size: 50,
color: Colors.blueGrey,
),
const SizedBox(height: 16),
Text(
message,
textAlign: TextAlign.center,
),
if (buttonText != null && onPressed != null) ...[
const SizedBox(height: 16),
ElevatedButton.icon(
onPressed: onPressed,
icon: const Icon(Icons.refresh),
label: Text(buttonText!),
),
],
],
),
),
);
}
}

void _showSourceInfo(
BuildContext context,
CameraPhoto camera,
) {
showDialog<void>(
context: context,
builder: (context) {
return AlertDialog(
title: const Text('Image Source and License'),
content: SingleChildScrollView(
child: SelectableText(
'Image: ${camera.title}\n\n'
'Source page:\n${camera.pageUrl}\n\n'
'Check the original Wikimedia Commons page for '
'the author, license, and attribution requirements.',
),
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text('Close'),
),
],
);
},
);
}