import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  ImageProvider _profileImage = const AssetImage('assets/ProfileEX1.jpg');

  File? _galleryImage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _galleryImage = File(pickedFile.path);
        _profileImage = FileImage(_galleryImage!);
      });
    }
  }

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
                onTap: () {
                  setState(() {
                    _profileImage = const AssetImage('assets/default_profile.png');
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('ProfileEX1'),
                onTap: () {
                  setState(() {
                    _profileImage = const AssetImage('assets/ProfileEX1.jpg');
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('ProfileEX2'),
                onTap: () {
                  setState(() {
                    _profileImage = const AssetImage('assets/ProfileEX2.jpg');
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

  void _saveProfile() {
    String name = _nameController.text;
    Navigator.pop(context, {
      'name': name,
      'image': _profileImage,
    });
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

            /// ✅ 프로필 이미지
            GestureDetector(
              onTap: _showImageOptions,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage,
              ),
            ),

            const SizedBox(height: 30),

            /// ✅ 이름 입력창
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '사용자 이름',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            /// ✅ 저장 버튼
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
