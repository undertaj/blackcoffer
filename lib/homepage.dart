
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';


class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late CameraController _controller;
  late List<CameraDescription> cameras;
  late String _videoPath;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (!_controller.value.isInitialized) {
      return;
    }

    final String videoPath = join(
      (await getTemporaryDirectory()).path,
      '${DateTime.now()}.mp4',
    );

    await _controller.startVideoRecording();
    setState(() {
      _videoPath = videoPath;
    });
  }

  Future<void> _stopRecording(BuildContext context) async {
    if (_controller.value.isRecordingVideo) {
      await _controller.stopVideoRecording();

      // TODO: Upload the video to Firebase Storage
      _uploadVideo(context);
    }
  }


  Future<void> _uploadVideo(BuildContext context) async {
    Reference storageRef = FirebaseStorage.instance.ref().child('videos/${basename(_videoPath)}');
    io.File videoFile = io.File(_videoPath);

    UploadTask uploadTask = storageRef.putFile(videoFile);

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      print('Progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
    }, onError: (Object e) {
      print('Error: $e');
    });

    uploadTask.whenComplete(() {
      print('Video uploaded successfully!');
      // TODO: Add logic for updating video details in Firestore (title, description, category, location)
      // ...
      Navigator.pop(context); // Close the PostVideoPage
    });
  }


  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Post Video'),
      ),
      body: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: CameraPreview(_controller),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _controller.value.isRecordingVideo ? () => _stopRecording(context) : _startRecording,
        child: Icon(_controller.value.isRecordingVideo ? Icons.stop : Icons.videocam),
      ),
    );
  }
}