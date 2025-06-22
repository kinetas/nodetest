import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../SessionTokenManager.dart';
import 'ChatBotAI_widget.dart';
import '../NewMissionScreen/SelectCreateMission.dart';

class AIChatConversationScreen extends StatefulWidget {
  @override
  _AIChatConversationScreenState createState() => _AIChatConversationScreenState();
}

class _AIChatConversationScreenState extends State<AIChatConversationScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool isLoading = false;
  String? lastUserInput;

  Future<void> _sendMessage({String? overrideText}) async {
    final text = overrideText ?? _controller.text.trim();
    if (text.isEmpty) return;

    lastUserInput = text;

    setState(() {
      messages.add({'sender': 'user', 'text': text});
      messages.add({'sender': 'ai', 'text': 'AI가 답변을 생성 중이에요…', 'isLoading': true}); // ✅ 로딩 메시지
      isLoading = true;
      _controller.clear();
    });

    final token = await SessionTokenManager.getToken();
    if (token == null) {
      setState(() {
        messages.removeWhere((msg) => msg['isLoading'] == true); // ✅ 제거
        messages.add({'sender': 'system', 'text': '❗ 토큰이 없습니다. 다시 로그인하세요.'});
        isLoading = false;
      });
      return;
    }

    final response = await http.post(
      Uri.parse("http://13.125.65.151:3000/ai/recommend"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"category": text}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        messages.removeWhere((msg) => msg['isLoading'] == true); // ✅ 로딩 제거
        messages.add({
          'sender': 'ai',
          'text': json["message"],
          'message': json["message"],
          'title': json["title"],
          'category': json["category"],
          'source': json["source"],
        });
        isLoading = false;
      });
    } else {
      setState(() {
        messages.removeWhere((msg) => msg['isLoading'] == true); // ✅ 로딩 제거
        messages.add({
          'sender': 'system',
          'text': '❗ 요청 실패 (${response.statusCode}): ${response.body}'
        });
        isLoading = false;
      });
    }
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isUser = message['sender'] == 'user';
    final isAI = message['sender'] == 'ai';
    final isLoadingMessage = message['isLoading'] == true;

    return ChatBotAIWidget(
      message: message['text'] ?? '',
      isUser: isUser,
      isLoading: isLoadingMessage,
      onRetryPressed: (!isUser && !isLoadingMessage && lastUserInput != null)
          ? () => _sendMessage(overrideText: lastUserInput)
          : null,
      onTapAdd: (!isUser && !isLoadingMessage)
          ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SelectCreateMission(
              initialTitle: message['title'] ?? message['text'] ?? '',
              initialCategory: message['category'] ?? '',
            ),
          ),
        );
      }
          : null,
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "카테고리나 메시지를 입력",
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue[600],
              radius: 24,
              child: IconButton(
                icon: Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text("AI 미션 채팅"),
        backgroundColor: Colors.blue[700],
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildMessage(messages[index]),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }
}