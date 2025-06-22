import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../../SessionTokenManager.dart';

class CreateFree extends StatefulWidget {
  @override
  _CreateFreeState createState() => _CreateFreeState();
}

class _CreateFreeState extends State<CreateFree> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _submit() async {
    final uri = Uri.parse('http://13.125.65.151:3000/nodetest/api/comumunity_missions/createGeneralCommunity');
    final request = http.MultipartRequest('POST', uri);

    final token = await SessionTokenManager.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("로그인이 필요합니다")));
      return;
    }

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['cr_title'] = _titleController.text;
    request.fields['contents'] = _contentController.text;
    request.fields['community_type'] = 'general';

    if (_image != null) {
      final mimeTypeData = lookupMimeType(_image!.path)?.split('/');
      if (mimeTypeData != null && mimeTypeData.length == 2) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image!.path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        ));
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success'] == true) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('작성 실패')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('서버 오류: ${response.statusCode}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자유게시판 글쓰기', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('등록', style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: '내용',
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text('사진 업로드', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: _image == null
                  ? Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[100],
                ),
                child: const Center(child: Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey)),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(_image!, height: 180, width: double.infinity, fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
    );
  }
}