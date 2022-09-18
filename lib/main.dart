import 'package:the_worst_dictionary_ever/details.dart';
import 'package:flutter/material.dart';
import 'model/word.dart';
import 'package:the_worst_dictionary_ever/db/database.dart';
import 'package:translator/translator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'The Worst Dictionary Ever',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final db = DictDatabase();
  final translator = GoogleTranslator();
  bool googleTrans = false;
  Word? r;
  List<Word> lr = [];
  TextEditingController txtCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    await db.db;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Dictionary'),
        ),
        body: Column(children: [
          Expanded(
            flex: 1,
            child: Container(
                padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Colors.grey])),
                child: Center(
                  child: TextField(
                      textInputAction: TextInputAction.search,
                      maxLines: 1,
                      controller: txtCtrl,
                      onChanged: (value) async {
                        if (value.isNotEmpty) {
                          var result = await db.searchWordResults(value);
                          if (result.isNotEmpty) {
                            setState(() {
                              lr = result;
                            });
                          } else {
                            setState(() {
                              lr.clear();
                              googleTrans = true;
                            });
                          }
                        } else {
                          setState(() {
                            lr.clear();
                            googleTrans = false;
                          });
                        }
                      },
                      onSubmitted: (value) async {
                        if (value.isNotEmpty) {
                          var result = await db.fetchWordByWord(value);
                          if (result != null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DetailScreen(
                                        word: result.word,
                                        pronounce: result.pronounce,
                                        meaning: result.meaning)));
                          } else {
                            try {
                              var meaning =
                                  await translator.translate(value, to: 'vi');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailScreen(
                                          word: value,
                                          pronounce: '',
                                          meaning: meaning.toString())));
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Check your internet connection!')));
                            }
                          }
                        }
                      },
                      decoration: InputDecoration(
                          hoverColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.only(top: 5, bottom: 5),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Enter something',
                          hintStyle:
                              const TextStyle(fontStyle: FontStyle.italic),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide:
                                  const BorderSide(color: Colors.transparent)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide:
                                  const BorderSide(color: Colors.transparent)),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey))),
                )),
          ),
          Expanded(flex: 9, child: reSult(lr))
        ]));
  }

  reSult(List<Word> lr) {
    if (lr.isNotEmpty) {
      return ListView.separated(
          itemCount: lr.length,
          itemBuilder: (BuildContext context, int index) {
            return resultDetail(lr, index);
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(thickness: 2));
    } else {
      if (googleTrans == false) {
        return const SizedBox();
      } else {
        return Container(
            padding: const EdgeInsets.only(top: 10),
            child: RichText(
                text: TextSpan(
                    style: Theme.of(context).textTheme.headline5,
                    children: const [
                  WidgetSpan(child: Icon(Icons.search)),
                  TextSpan(text: ' to use Google Translate')
                ])));
      }
    }
  }

  resultDetail(List<Word> lr, int index) {
    return GestureDetector(
        child: Container(
            height: 50,
            padding: const EdgeInsets.only(left: 20, right: 20, top: 3),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text(lr[index].word,
                        maxLines: 1,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold))),
                lr[index].pronounce.isNotEmpty
                    ? Expanded(
                        child: Text(lr[index].pronounce,
                            maxLines: 1,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)))
                    : const SizedBox()
              ]),
              const SizedBox(height: 5),
              Expanded(
                  child: Text(lr[index].meaning,
                      style: const TextStyle(fontSize: 11, color: Colors.grey)))
            ])),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailScreen(
                      word: lr[index].word,
                      pronounce: lr[index].pronounce,
                      meaning: lr[index].meaning)));
        });
  }
}
