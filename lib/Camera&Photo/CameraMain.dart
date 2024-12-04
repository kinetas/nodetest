import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission(); // 권한 체크 및 초기화 호출
  }

  Future<void> _checkCameraPermission() async {
    if (await Permission.camera.request().isGranted) {
      await _initializeCamera(); // 권한이 허용되면 카메라 초기화
    } else {
      print("카메라 권한이 거부되었습니다.");
      _showPermissionDialog(); // 권한 거부 시 안내 메시지
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // 사용 가능한 카메라 가져오기
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(
          _cameras[_selectedCameraIndex],
          ResolutionPreset.high,
        );

        // 카메라 초기화
        await _cameraController.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      } else {
        print("사용 가능한 카메라가 없습니다.");
      }
    } catch (e) {
      print("카메라 초기화 중 에러: $e");
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("카메라 권한 필요"),
        content: Text("카메라를 사용하려면 권한이 필요합니다."),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              if (await Permission.camera.request().isGranted) {
                await _initializeCamera(); // 권한 허용 후 초기화
              } else {
                print("카메라 권한이 여전히 거부되었습니다.");
              }
            },
            child: Text("권한 요청"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("취소"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _capturePhoto() async {
    try {
      final image = await _cameraController.takePicture();
      print("사진 저장 경로: ${image.path}");
      // 사진 저장 및 미리보기 화면으로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayPhotoScreen(imagePath: image.path),
        ),
      );
    } catch (e) {
      print("사진 촬영 에러: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("카메라"),
        actions: [
          IconButton(
            icon: Icon(Icons.cameraswitch),
            onPressed: _isCameraInitialized ? _switchCamera : null,
          ),
        ],
      ),
      body: _isCameraInitialized
          ? Stack(
        children: [
          CameraPreview(_cameraController), // 카메라 미리보기
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: _capturePhoto,
                child: Icon(Icons.camera_alt),
              ),
            ),
          ),
        ],
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _switchCamera() async {
    if (_cameras.isNotEmpty) {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
      _cameraController = CameraController(
        _cameras[_selectedCameraIndex],
        ResolutionPreset.high,
      );
      await _cameraController.initialize();
      setState(() {});
    }
  }
}

class DisplayPhotoScreen extends StatelessWidget {
  final String imagePath;

  DisplayPhotoScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("사진 미리보기"),
      ),
      body: Center(
        child: Image.file(File(imagePath)), // 저장된 사진 불러오기
      ),
    );
  }
}