import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/api_service.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final ApiService _api = ApiService();
  late Future<List<Post>> _postsFuture;
  final List<Post> _createdPosts = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Future створюється ОДИН раз і зберігається у змінній, а не в build().
    _postsFuture = _api.getPosts();
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  /// Кнопка Retry: новий запит і перемальовування екрана.
  void _retry() {
    setState(() {
      _postsFuture = _api.getPosts();
    });
  }

  /// Pull-to-refresh: RefreshIndicator чекає, поки Future завершиться.
  Future<void> _refresh() async {
    final newFuture = _api.getPosts();
    setState(() {
      _postsFuture = newFuture;
    });
    try {
      await newFuture;
    } catch (e) {
      _showMessage('Не вдалося оновити: $e');
    }
  }

  Future<void> _showCreateDialog() async {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Нова заявка'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Тема заявки'),
            ),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(labelText: 'Опис проблеми'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Надіслати'),
          ),
        ],
      ),
    );

    if (shouldSend != true) return;

    final title = titleController.text.trim();
    final body = bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      _showMessage('Заповніть тему й опис');
      return;
    }

    setState(() {
      _isSending = true;
    });
    try {
      final created = await _api.createPost(title, body);
      if (!mounted) return;
      setState(() {
        _createdPosts.insert(0, created);
      });
      _showMessage('Заявку створено, id = ${created.id}');
    } on ApiException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Невідома помилка: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Widget _buildError(Object? error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        Text(
          'Помилка: $error',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            onPressed: _retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Повторити (Retry)'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заявки на обладнання'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Оновити',
            onPressed: _retry,
          ),
        ],
        bottom: _isSending
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Post>>(
          future: _postsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return _buildError(snapshot.error);
            } else {
              final posts = [..._createdPosts, ...snapshot.data!];
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text('${post.id}')),
                    title: Text(
                      post.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      post.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSending ? null : _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Нова заявка'),
      ),
    );
  }
}