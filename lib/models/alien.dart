class Alien {
  final int id;
  final String question;
  final String answer;
  final String imagePath;

  Alien({
    required this.id,
    required this.question,
    required this.answer,
    required this.imagePath,
  });

  factory Alien.fromJson(Map<String, dynamic> json) {
    return Alien(
      id: json['id'] as int,
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      imagePath: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'image': imagePath,
    };
  }
}
