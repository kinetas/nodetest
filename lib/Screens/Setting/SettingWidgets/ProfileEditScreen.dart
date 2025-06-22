import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../../../SessionTokenManager.dart';
import 'dart:typed_data';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  ImageProvider _profileImage = const AssetImage('assets/ProfileEX1.jpg');
  File? _uploadImageFile; // 서버에 업로드할 실제 파일

  // ✅ assets 이미지를 임시 파일로 변환
  Future<File> _assetToFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final Uint8List bytes = byteData.buffer.asUint8List();
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${path.basename(assetPath)}');
    await file.writeAsBytes(bytes);
    return file;
  }

  // ✅ 갤러리에서 이미지 선택
  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      print('📸 [Gallery] 이미지 선택됨: ${pickedFile.path}');
      setState(() {
        _uploadImageFile = File(pickedFile.path);
        _profileImage = FileImage(_uploadImageFile!);
      });
    } else {
      print('❌ [Gallery] 이미지 선택 안됨');
    }
  }

  // ✅ 이미지 선택 옵션 표시
  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('기본 이미지로 변경'),
                onTap: () async {
                  print('🔁 기본 이미지 선택');
                  String assetPath = 'assets/ProfileEX1.jpg'; // 원하는 기본이미지 경로
                  File file = await _assetToFile(assetPath);
                  setState(() {
                    _profileImage = AssetImage(assetPath);
                    _uploadImageFile = file;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('ProfileEX1'),
                onTap: () async {
                  print('🖼️ 예제 이미지 ProfileEX1 선택');
                  String assetPath = 'assets/ProfileEX1.jpg';
                  File file = await _assetToFile(assetPath);
                  setState(() {
                    _profileImage = AssetImage(assetPath);
                    _uploadImageFile = file;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('ProfileEX2'),
                onTap: () async {
                  print('🖼️ 예제 이미지 ProfileEX2 선택');
                  String assetPath = 'assets/ProfileEX2.jpg';
                  File file = await _assetToFile(assetPath);
                  setState(() {
                    _profileImage = AssetImage(assetPath);
                    _uploadImageFile = file;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리에서 선택'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ 저장 버튼 동작
  Future<void> _saveProfile() async {
    print('💾 저장 버튼 눌림');

    if (_uploadImageFile == null) {
      print('⚠️ 업로드할 이미지 없음');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지를 선택해주세요.')),
      );
      return;
    }

    final uri = Uri.parse('http://13.125.65.151:3000/auth/api/user-info/chaingeProfileImage');
    final token = await SessionTokenManager.getToken();

    if (token == null) {
      print('❌ 토큰 없음');
      return;
    }

    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // 서버 요구사항에 맞춘 키
          _uploadImageFile!.path,
          filename: path.basename(_uploadImageFile!.path),
        ),
      );

      print('📤 서버로 이미지 업로드 시도 중...');
      final response = await request.send();

      if (response.statusCode == 200) {
        print('✅ 이미지 업로드 성공');
        Navigator.pop(context, {'image': _profileImage});
      } else {
        print('❌ 이미지 업로드 실패: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('업로드 실패: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('❌ 업로드 중 예외 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('업로드 중 오류가 발생했습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('프로필 편집'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            // ✅ 프로필 이미지 표시 및 클릭
            GestureDetector(
              onTap: _showImageOptions,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage,
              ),
            ),
            const SizedBox(height: 30),
            // ✅ 저장 버튼
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                '저장',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
