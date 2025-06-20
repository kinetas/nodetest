import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../SessionTokenManager.dart';

class CreateRecruit extends StatefulWidget {
  @override
  _CreateRecruitState createState() => _CreateRecruitState();
}

class _CreateRecruitState extends State<CreateRecruit> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedCategory;
  DateTime? _selectedDate;

  final List<String> _categories = ['운동', '공부', '습관', '식단'];

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty || _selectedDate == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('모든 항목을 입력해주세요')));
      return;
    }

    final token = await SessionTokenManager.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('로그인이 필요합니다')));
      return;
    }

    final url = Uri.parse('http://27.113.11.48:3000/nodetest/api/comumunity_missions/create');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'cr_title': title,
        'contents': content,
        'deadline': _selectedDate!.toIso8601String().split('T')[0],
        'category': _selectedCategory,
      }),
    );

    final result = jsonDecode(response.body);

    if (response.statusCode == 200 && result['success'] == true) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('작성 실패: ${result['message'] ?? '오류'}')));
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('미션 구인 글쓰기', style: TextStyle(color: Colors.black)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '제목',
                labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _contentController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: '내용',
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: '카테고리',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        hint: Text('선택하세요'),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedCategory = value),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('기한', style: TextStyle(fontSize: 16)),
              trailing: TextButton(
                onPressed: _pickDate,
                child: Text(
                  _selectedDate == null ? '선택' : _selectedDate!.toString().split(' ')[0],
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: Icon(Icons.check),
                label: Text('등록하기', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}