import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Connect to Web socket server
  final channel = WebSocketChannel.connect(
    Uri.parse('wss://echo.websocket.events'),
  );

  @override
  void dispose() {
    _messageController.dispose();

    // closing the channel
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WEB SOCKET"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Message"),
                    floatingLabelStyle: TextStyle(color: Colors.black87),
                    labelStyle: TextStyle(color: Colors.black38)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter message";
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {

                    final message = _messageController.text.trim();
                    // sending message
                    channel.sink.add(message);
                    _messageController.clear();
                    FocusScope.of(context).unfocus();
                  }
                },
                child: const Text("Send"),
              ),
              const SizedBox(
                height: 32,
              ),

              // Listening message from the web socket
              StreamBuilder(
                 // Get stream from the channel
                stream: channel.stream,
                builder: (context, snapShot) {
                  return Text(snapShot.hasData ? "${snapShot.data}" : "");
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
