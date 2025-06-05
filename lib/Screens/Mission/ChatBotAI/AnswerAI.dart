class AnswerAI {
  final String message;
  final String title;
  final String category;
  final String source;
  final double responseTime;

  AnswerAI({
    required this.message,
    required this.title,
    required this.category,
    required this.source,
    required this.responseTime,
  });

  factory AnswerAI.fromJson(Map<String, dynamic> json) {
    return AnswerAI(
      message: json['message'],
      title: json['title'],
      category: json['category'],
      source: json['source'],
      responseTime: json['response_time_sec'].toDouble(),
    );
  }
}