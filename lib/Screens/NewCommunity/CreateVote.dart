import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../../SessionTokenManager.dart';

class CreateVote extends StatefulWidget {
  @override
  _CreateVoteState createState() => _CreateVoteState();
}

class _CreateVoteState extends State<CreateVote> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('제목과 내용을 입력해주세요.')));
      return;
    }

    final token = await SessionTokenManager.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }

    final uri = Uri.parse('http://27.113.11.48:3000/nodetest/api/cVote/create');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['c_title'] = title;
    request.fields['c_contents'] = content;

    if (_image != null) {
      final mimeType = lookupMimeType(_image!.path)?.split('/');
      if (mimeType != null && mimeType.length == 2) {
        request.files.add(await http.MultipartFile.fromPath(
          'c_image',
          _image!.path,
          contentType: MediaType(mimeType[0], mimeType[1]),
        ));
      }
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success'] == true) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('투표가 성공적으로 생성되었습니다.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('생성 실패: ${result['message'] ?? '오류'}')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('서버 오류: ${response.statusCode}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('미션투표 글쓰기', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text('등록', style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: '제목을 입력하세요',
              border: InputBorder.none,
              hintStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: '내용을 입력하세요',
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickImage,
            child: _image == null
                ? Container(
              height: 200,
              color: Colors.grey[300],
              child: Icon(Icons.image, size: 48, color: Colors.grey),
            )
                : Image.file(_image!, height: 200, fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }
}