class Word {
  final String word;
  final String pronounce;
  final String meaning;

  Word({required this.word, required this.pronounce, required this.meaning});

  Word.fromJson(Map<String, dynamic> json)
      : word = json['word'],
        pronounce = json['pronounce'],
        meaning = json['meaning'];
}
