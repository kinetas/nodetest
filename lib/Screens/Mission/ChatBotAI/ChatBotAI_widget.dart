import 'package:flutter/material.dart';
import 'package:capstone_1_project/Screens/Mission/NewMissionScreen/SelectCreateMission.dart';

class ChatBotAIWidget extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool isLoading; // ✅ AI 응답 로딩 상태
  final VoidCallback? onRetryPressed;
  final VoidCallback? onTapAdd;

  const ChatBotAIWidget({
    super.key,
    required this.message,
    required this.isUser,
    this.isLoading = false, // 기본값 false
    this.onRetryPressed,
    this.onTapAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isUser ? Colors.blue[600] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(1, 2),
                blurRadius: 4,
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoading ? "AI가 답변을 생성 중이에요…" : message,
                  style: TextStyle(
                    color: isUser ? Colors.white : Colors.black87,
                    fontSize: 15,
                    fontStyle: isLoading ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
                if (!isUser && !isLoading) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onTapAdd ?? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SelectCreateMission(
                                  initialTitle: message,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_task),
                          label: const Text("미션 추가"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      if (onRetryPressed != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onRetryPressed,
                            icon: const Icon(Icons.refresh),
                            label: const Text("다시 생성"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: const BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}