import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'services/network/device_network_service.dart';

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
  static const int _serverPort = 8080;
  static const Duration _connectionTimeout = Duration(seconds: 5);

  ServerSocket? server;
  Socket? socket;
  List<String> messages = [];
  TextEditingController controller = TextEditingController();

  final DeviceNetworkService _networkService = DeviceNetworkService();

  // 🔹 START SERVER
  void startServer() async {
    try {
      server = await ServerSocket.bind(InternetAddress.anyIPv4, _serverPort);

      final deviceIp = await _networkService.getLocalIp();
      setState(() {
        messages.add("Server started on $deviceIp:$_serverPort");
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
        messages.add("Server Error: $e");
      });
    }
  }

  // 🔹 CONNECT TO SERVER
  void connectToServer() async {
    final deviceIp = await _networkService.getLocalIp();

    // Try device LAN IP first, then fall back to localhost.
    final candidates = [deviceIp, '127.0.0.1'];

    for (final host in candidates) {
      try {
        socket = await Socket.connect(host, _serverPort)
            .timeout(_connectionTimeout);

        setState(() {
          messages.add("Connected to server at $host:$_serverPort");
        });

        socket!.listen((data) {
          String msg = utf8.decode(data);
          setState(() {
            messages.add("Server: $msg");
          });
        });
        return;
      } catch (e) {
        setState(() {
          messages.add("Connection Failed ($host:$_serverPort): $e");
        });
      }
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