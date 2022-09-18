import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen(
      {Key? key,
      required this.word,
      required this.pronounce,
      required this.meaning})
      : super(key: key);

  final String word;
  final String pronounce;
  final String meaning;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(word,
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            pronounce.isEmpty ? const SizedBox() : const SizedBox(height: 5),
            Text(pronounce, style: const TextStyle(fontSize: 13)),
            Text(fixed(), style: const TextStyle(fontSize: 15))
          ]),
        ));
  }

  fixed() {
    String fixed;
    fixed = meaning.replaceAll('@', '\n\n@');
    fixed = fixed.replaceAll('-', '\n-');
    fixed = fixed.replaceAll('*', '\n\n*');
    return fixed;
  }
}
