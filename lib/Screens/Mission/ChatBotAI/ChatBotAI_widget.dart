import 'package:flutter/material.dart';

// ChatBotAI_widget.dart
class ChatBotAIWidget extends StatelessWidget {
  final String message;
  final bool isUser;
  final VoidCallback? onAddPressed;
  final VoidCallback? onRetryPressed;

  const ChatBotAIWidget({
    super.key,
    required this.message,
    required this.isUser,
    this.onAddPressed,
    this.onRetryPressed,
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
            boxShadow: [
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
                  message,
                  style: TextStyle(
                    color: isUser ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                ),
                if (!isUser && (onAddPressed != null || onRetryPressed != null)) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (onAddPressed != null)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onAddPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: Text("이 미션 추가하기"),
                          ),
                        ),
                      if (onRetryPressed != null)
                        const SizedBox(width: 8),
                      if (onRetryPressed != null)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onRetryPressed,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: BorderSide(color: Colors.blue),
                            ),
                            child: Text("다시 생성하기"),
                          ),
                        ),
                    ],
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}