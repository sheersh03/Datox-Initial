import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../core/storage/secure_store.dart';

class ChatScreen extends StatefulWidget {
  final String matchId;
  const ChatScreen({super.key, required this.matchId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late WebSocketChannel channel;
  final ctrl = TextEditingController();
  final messages = <String>[];

  @override
  void initState() {
    super.initState();
    connect();
  }

  Future<void> connect() async {
    final token = await SecureStore.read('token');
    channel = WebSocketChannel.connect(
      Uri.parse(
          'ws://localhost:8080/ws/chat?match_id=${widget.matchId}&token=$token'),
    );

    channel.stream.listen((event) {
      final data = jsonDecode(event);
      if (data['type'] == 'message') {
        setState(() => messages.add(data['data']['content']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: messages.map((m) => ListTile(title: Text(m))).toList(),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(controller: ctrl),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  channel.sink.add(jsonEncode({
                    'type': 'message',
                    'content': ctrl.text,
                  }));
                  ctrl.clear();
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
