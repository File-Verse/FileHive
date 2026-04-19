import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ServerSocket? server;
  Socket? socket;
  List<String> messages = [];
  TextEditingController controller = TextEditingController();

  // 🔹 START SERVER
  void startServer() async {
    try {
      server = await ServerSocket.bind(InternetAddress.anyIPv4, 3000);

      setState(() {
        messages.add("Server started");
      });

      server!.listen((client) {
        socket = client;

        client.listen((data) {
          String msg = utf8.decode(data);
          setState(() {
            messages.add("Client: $msg");
          });
        });
      });
    } catch (e) {
      setState(() {
        messages.add("Server Error");
      });
    }
  }

  // 🔹 CONNECT TO SERVER
  void connectToServer() async {
    try {
      socket = await Socket.connect("10.66.212.46", 3000)
          .timeout(Duration(seconds: 5));

      setState(() {
        messages.add("Connected to server");
      });

      socket!.listen((data) {
        String msg = utf8.decode(data);
        setState(() {
          messages.add("Server: $msg");
        });
      });
    } catch (e) {
      setState(() {
        messages.add("Connection Failed");
      });
    }
  }

  // 🔹 SEND MESSAGE
  void sendMessage() {
    if (socket != null && controller.text.isNotEmpty) {
      socket!.write(controller.text);

      setState(() {
        messages.add("Me: ${controller.text}");
      });

      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("FileHive Chat")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: startServer,
            child: Text("Start Server"),
          ),

          ElevatedButton(
            onPressed: connectToServer,
            child: Text("Connect"),
          ),

          Expanded(
            child: ListView(
              children: messages
                  .map((msg) => ListTile(title: Text(msg)))
                  .toList(),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: "Enter message"),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: sendMessage,
              )
            ],
          )
        ],
      ),
    );
  }
}