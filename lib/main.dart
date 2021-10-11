import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.dark,
        primaryColor: Colors.lightBlue[800],

        // Define the default font family.
        fontFamily: 'Georgia',

        // Define the default `TextTheme`. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: const TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      title: 'Named Routes Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => FirstScreen(title: 'CHAT386'),
        '/second': (context) => SecondScreen(title: 'SAIR'),
      },
    );
  }
}

class FirstScreen extends StatefulWidget {
  final String title;

  const FirstScreen({required this.title});

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final TextEditingController _controllerNick = TextEditingController();
  String _nickName = '';

  //final TextEditingController _controllerMessage = TextEditingController();
  @override
  void initState() {
    super.initState();
    _controllerNick.addListener(_updateNick);
  }

  @override
  void dispose() {
    _controllerNick.dispose();
    super.dispose();
  }

  _updateNick() {
    _nickName = _controllerNick.text.toUpperCase();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar:
      AppBar(title: Text(widget.title, style: GoogleFonts.pressStart2p())),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              margin: EdgeInsets.only(left: 20),
              child: TextField(
                controller: _controllerNick,
                style: GoogleFonts.pressStart2p(),
                onSubmitted: (value) { Navigator.pushNamed(context, '/second', arguments: _nickName);},
                decoration: new InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.greenAccent, width: 5.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.yellow, width: 5.0),
                  ),
                  hintText: 'NickName',
                ),
              ), // <-- Wrapped in Flexible.
            ),
            Container(
              width: 300,
              height: 50,
              margin: EdgeInsets.only(left: 20),
              child: ElevatedButton(
                  onPressed:  () { Navigator.pushNamed(context, '/second', arguments: _nickName);},
                  child: Text("Entrar no chat",
                      style: GoogleFonts.pressStart2p())),
            )
          ],
        ),
      ),
    );
  }
}
//teste commit
class SecondScreen extends StatefulWidget {
  final String title;

  SecondScreen({required this.title});

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  final TextEditingController _controllerMessage = TextEditingController();
  String _myNick = '';
  String _myMessage = '';
  static bool enterChat = false;
  Map<String, BoxMessage> users = Map();

  @override
  void initState() {
    super.initState();
    enterChat = false;
    _controllerMessage.addListener(_updateMessage);
  }

  @override
  void dispose() {
    _getOut();
    _channel.sink.close();
    _controllerMessage.dispose();
    super.dispose();
  }

  void _updateMessage() {
    update();
    var jsonData = Map<String, String>();
    jsonData["action"] = "broadcast";
    jsonData["username"] = _myNick;
    jsonData["message"] = _myMessage;
    _channel.sink.add(json.encode(jsonData));
    print('Second text field: ${_controllerMessage.text}');
  }

  void _updateUsername() {
    var jsonData = Map<String, String>();
    jsonData["action"] = "username";
    jsonData["username"] = _myNick;
    _channel.sink.add(json.encode(jsonData));
  }

  void _getOut() {
    var jsonData = Map<String, String>();
    jsonData["action"] = "left";
    _channel.sink.add(json.encode(jsonData));
  }

  update() {
    setState(() {
      _myMessage = _controllerMessage.text;
    });
  }

  final _channel = WebSocketChannel.connect(
    Uri.parse('ws://chat386.herokuapp.com/ws'),
    //Uri.parse('ws://127.0.0.1:8080/ws'),
  );

  @override
  Widget build(BuildContext context) {
    _myNick = ModalRoute.of(context)?.settings.arguments as String;
    print(enterChat);
    if (enterChat == false) {
      _updateUsername(); //atualiza nick name quando entra para a sala
      //print(_myNick);
      enterChat = true;
    }
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.title, style: GoogleFonts.pressStart2p()),
          leading: new IconButton(
              icon: new Icon(Icons.arrow_back, color: Colors.orange),
              onPressed: () {
                //_getOut();
                Navigator.of(context).pop();
              })),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Container(
                height: 300,
                width: 400,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.black),
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _myNick,
                      style: GoogleFonts.pressStart2p(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 30,
                          fontStyle: FontStyle.italic,

                        ),
                      ),
                    ),
                    Divider(height: 15,thickness: 10,color: Colors.yellow,),
                    SizedBox(height: 25),
                    Text(
                      _myMessage,
                      style: GoogleFonts.pressStart2p(
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w100)),
                    ),
                  ],
                ),
              ),

              StreamBuilder(
                  stream: _channel.stream,
                  builder: (context, snapshot) {
                    dynamic value = jsonDecode(snapshot.data.toString());
                    print(value);
                    if (value != null && value['action'] == 'list_users') {
                      print(value['connected_users']);
                      //users.de
                      if (value['removed'] != null)users.remove(value['removed']);
                      for (var username in value['connected_users']) {
                        if (username != _myNick)
                          users[username] =
                              BoxMessage(nick: username, message: '');
                      }
                    }
                    if (value != null && value['action'] == 'broadcast') {
                      if (value['username'] != _myNick)
                        users[value['username']] = BoxMessage(
                            nick: value['username'], message: value['message']);
                    }

                    return Expanded(
                      child: Wrap(
                          runSpacing: 1,
                          //crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: users.entries.map((entry) {
                            var w = entry.value;
                            return w;
                          }).toList()
                      ),
                    );
                  }),
            ],
          ),
        ),
        Container(
          width: 400,
          height: 100,
          margin: EdgeInsets.all(20),
          child: TextField(
            style: GoogleFonts.pressStart2p(),
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            controller: _controllerMessage,
            decoration: new InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary, width: 5.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary, width: 5.0),
              ),
              hintText: 'Message',
            ),
          ), // <-- Wrapped in Flexible.
        )
      ]),
    );
  }
}

class BoxMessage extends StatelessWidget {
  const BoxMessage({required this.nick, required this.message});

  final String nick;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 400,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50), color: Colors.black),
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          nick,
          style: GoogleFonts.pressStart2p(
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 30,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        Divider(height: 15,thickness: 10,color: Colors.yellow,),
        SizedBox(height: 15),
        Text(
          message,
          style: GoogleFonts.pressStart2p(
              textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w100)),
        ),
      ]),
    );

  }
}

// class BoxMessage extends StatelessWidget {
//   const BoxMessage({
//     required this.value,
//     required this.nick,
//   });
//
//   final value;
//   final String nick;
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//         child: Container(
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(50), color: Colors.black),
//       margin: EdgeInsets.all(20),
//       padding: EdgeInsets.all(20),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Text(
//           value['action'] == 'broadcast' && value['username'] != nick
//               ? '${(value['username'])}'
//               : '',
//           style: GoogleFonts.pressStart2p(
//             textStyle: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               fontSize: 30,
//               fontStyle: FontStyle.italic,
//               decoration: TextDecoration.underline,
//             ),
//           ),
//         ),
//         SizedBox(height: 15),
//         Text(
//           value['action'] == 'broadcast' && value['username'] != nick
//               ? '${(value['message'])}'
//               : '',
//           style: GoogleFonts.pressStart2p(
//               textStyle: TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                   letterSpacing: 1.5,
//                   fontWeight: FontWeight.w100)),
//         ),
//       ]),
//     ));
//   }
// }
