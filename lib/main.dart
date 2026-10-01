import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'OpenCode Chat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: const Color(0xFF6C63FF),
        ),
        home: const ChatPage(),
      );
}

class Msg {
  final String text;
  final bool me;
  Msg(this.text, this.me);
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String url = 'http://127.0.0.1:4096';
  final input = TextEditingController();
  final scroll = ScrollController();
  final msgs = <Msg>[];
  String? sid;
  bool busy = false;
  final headers = {'Content-Type': 'application/json'};

  void scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) {
        scroll.animateTo(scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> send() async {
    final t = input.text.trim();
    if (t.isEmpty || busy) return;
    input.clear();
    setState(() {
      msgs.add(Msg(t, true));
      busy = true;
    });
    scrollDown();
    String reply;
    try {
      if (sid == null) {
        final r = await http.post(Uri.parse('$url/session'),
            headers: headers, body: '{}');
        sid = jsonDecode(r.body)['id'];
      }
      final r = await http
          .post(Uri.parse('$url/session/$sid/message'),
              headers: headers,
              body: jsonEncode({
                'parts': [
                  {'type': 'text', 'text': t}
                ]
              }))
          .timeout(const Duration(minutes: 10));
      final data = jsonDecode(utf8.decode(r.bodyBytes));
      reply = (data['parts'] as List)
          .where((p) => p['type'] == 'text')
          .map((p) => p['text'])
          .join('\n');
      if (reply.isEmpty) reply = '(text reply nahi aaya)';
    } catch (e) {
      reply = 'Error: $e\n\nTermux me "opencode serve --port 4096" chal raha hai?';
    }
    setState(() {
      msgs.add(Msg(reply, false));
      busy = false;
    });
    scrollDown();
  }

  void settings() {
    final c = TextEditingController(text: url);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Server URL'),
        content: TextField(controller: c),
        actions: [
          TextButton(
            onPressed: () {
              url = c.text.trim();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget bubble(Msg m) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: m.me ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.all(12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        decoration: BoxDecoration(
          color: m.me ? cs.primaryContainer : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SelectableText(m.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenCode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'New chat',
            onPressed: () => setState(() {
              msgs.clear();
              sid = null;
            }),
          ),
          IconButton(icon: const Icon(Icons.settings), onPressed: settings),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: msgs.isEmpty
                ? const Center(child: Text('Kuch likho...'))
                : ListView.builder(
                    controller: scroll,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: msgs.length,
                    itemBuilder: (_, i) => bubble(msgs[i]),
                  ),
          ),
          if (busy) const LinearProgressIndicator(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: input,
                      minLines: 1,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Message likho',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: busy ? null : send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
