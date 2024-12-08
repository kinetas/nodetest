import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'PhotoWaterMark.dart'; // PhotoWaterMark 화면 import

class CameraScreen extends StatefulWidget {
  final String rId;
  final String u2Id;

  CameraScreen({required this.rId, required this.u2Id});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  String? _capturedPhotoPath;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    if (await Permission.camera.request().isGranted) {
      await _initializeCamera();
    } else {
      print("카메라 권한이 거부되었습니다.");
      _showPermissionDialog();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(
          _cameras[_selectedCameraIndex],
          ResolutionPreset.high,
        );

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
                await _initializeCamera();
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

  Future<void> _capturePhoto() async {
    try {
      // 기존 사진 삭제
      if (_capturedPhotoPath != null && File(_capturedPhotoPath!).existsSync()) {
        await File(_capturedPhotoPath!).delete();
        print("기존 사진 삭제 완료");
      }

      // 새로운 사진 촬영
      final XFile image = await _cameraController.takePicture();
      setState(() {
        _capturedPhotoPath = image.path; // 새로운 사진 경로 저장
        print("새로 찍은 사진 경로: $_capturedPhotoPath");
      });
    } catch (e) {
      print("사진 촬영 에러: $e");
    }
  }

  void _goToPhotoWaterMark() {
    if (_capturedPhotoPath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoWaterMark(
            imagePath: _capturedPhotoPath!, // 촬영된 사진 경로 전달
            rId: widget.rId,               // rId 전달
            u2Id: widget.u2Id,             // u2Id 전달
          ),
        ),
      );
    } else {
      print("사진 경로가 설정되지 않았습니다!");
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
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
          if (_capturedPhotoPath == null)
            CameraPreview(_cameraController),
          if (_capturedPhotoPath != null)
            Image.file(
              File(_capturedPhotoPath!),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          if (_capturedPhotoPath == null)
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
          if (_capturedPhotoPath != null)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _capturedPhotoPath = null; // 다시 찍기
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.7),
                    ),
                    child: Text("다시 찍기", style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_capturedPhotoPath != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhotoWaterMark(
                              imagePath: _capturedPhotoPath!, // 정확한 매개변수 이름
                              rId: widget.rId,
                              u2Id: widget.u2Id,
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.7),
                    ),
                    child: Text("다음", style: TextStyle(color: Colors.white)),
                  ),
                ],
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