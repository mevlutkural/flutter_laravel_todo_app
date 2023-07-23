import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo_app/screens/add_page.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List items = [];
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo app')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        label: const Text('add todo'),
        icon: const Icon(Icons.add),
      ),
      body: Visibility(
        visible: isLoaded,
        replacement: const Center(child: CircularProgressIndicator()),
        child: RefreshIndicator(
          onRefresh: fetchTodos,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index] as Map;
              final id = item['todo_id'];

              return ListTile(
                leading: CircleAvatar(child: Text((index + 1).toString())),
                title: Text(item['title']),
                subtitle: Text(item['description']),
                trailing: PopupMenuButton(
                  onSelected: (value) => {
                    if (value == 'edit')
                      {print('edit')}
                    else if (value == 'delete')
                      {deleteTodo(id)}
                  },
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ];
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void navigateToAddPage() {
    final route = MaterialPageRoute(builder: (context) => const AddTodoPage());

    Navigator.push(context, route);
  }

  Future<void> deleteTodo(int id) async {
    final url = 'http://todo-app.test/api/todos/$id';
    final uri = Uri.parse(url);
    final res = await http.delete(uri);

    if (res.statusCode == 200) {
      setState(() {
        items = items.where((item) => item['todo_id'] != id).toList();
      });
      successMessage('Todo item deleted successfully.');
    } else {
      errorMessage('Todo item could not be deleted.');
    }
  }

  Future<void> fetchTodos() async {
    const url = 'http://todo-app.test/api/todos';
    final uri = Uri.parse(url);
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      final todos = json as List;
      setState(() {
        items = todos;
        isLoaded = true;
      });
    }
  }

  void successMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void errorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
