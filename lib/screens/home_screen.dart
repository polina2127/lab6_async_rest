import 'package:flutter/material.dart';

import 'compare_screen.dart';
import 'posts_screen.dart';
import 'stream_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Облік обладнання: ЛР №6')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_download),
              title: const Text('Заявки на обладнання (REST API)'),
              subtitle: const Text('GET, POST, Retry, pull-to-refresh'),
              onTap: () => _open(context, const PostsScreen()),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Stream: лічильник'),
              subtitle: const Text('StreamController + StreamBuilder'),
              onTap: () => _open(context, const StreamScreen()),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.compare_arrows),
              title: const Text('Future проти Stream'),
              subtitle: const Text('FutureBuilder і StreamBuilder разом'),
              onTap: () => _open(context, const CompareScreen()),
            ),
          ),
        ],
      ),
    );
  }
}