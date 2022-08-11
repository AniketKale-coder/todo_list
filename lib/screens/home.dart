import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_list/models/db.dart';
import 'package:todo_list/providers/db.dart';

class TodoCard extends HookConsumerWidget {
  final int id;

  const TodoCard(this.id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(dbProvider);
    final todoProvider_ = ref.watch(todoProvider(id));
    return todoProvider_.maybeWhen(
        data: (todo) => Card(
              elevation: 5.0,
              margin: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 5.0,
              ),
              child: Container(
                padding: const EdgeInsets.all(5.0),
                child: ListTile(
                  title: Text(
                    todo['todo'],
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  trailing: InkWell(
                      onTap: () {
                        db.deletedata(todo['id']);
                      },
                      child: const Icon(Icons.delete)),
                ),
              ),
            ),
        orElse: () => const Center(
              child: Text(
                "No Data",
              ),
            ));
  }
}

class HomeScreen extends HookConsumerWidget {
  HomeScreen({Key? key}) : super(key: key);

  TextEditingController txt = TextEditingController();

  final db = TodoDatabase.instance;
  String? editval;
  String? errtext;
  bool validated = true;
  var myitems = [];
  List<Widget> children = <Widget>[];

  Future<bool> query() async {
    var allrows = await db.queryall();

    return Future.value(true);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(dbProvider);
    final todos = ref.watch(todosProvider);
    void addtodo() async {
      Map<String, dynamic> row = {
        TodoDatabase.columnName: editval,
      };
      final id = await db.insert(row);
      Navigator.pop(context);
      editval = "";
      validated = true;
      errtext = "";
    }

    void showalertdialog() {
      txt.text = "";
      showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  title: const Text(
                    "Add Task",
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: txt,
                        autofocus: true,
                        onChanged: (val) {
                          editval = val;
                        },
                        style: const TextStyle(
                          fontSize: 18.0,
                        ),
                        decoration: InputDecoration(
                          errorText: validated ? null : errtext,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                if (txt.text.isEmpty) {
                                  setState(() {
                                    errtext = "Can't Be Empty";
                                    validated = false;
                                  });
                                } else if (txt.text.length > 512) {
                                  setState(() {
                                    errtext = "Too may Chanracters";
                                    validated = false;
                                  });
                                } else {
                                  addtodo();
                                }
                              },
                              child: const Text(
                                "ADD",
                                style: TextStyle(
                                  fontSize: 18.0,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          });
    }

    return todos.when(
      data: (myitems) {
        if (myitems.isEmpty) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: showalertdialog,
              child: const Icon(
                Icons.add,
              ),
            ),
            appBar: AppBar(
              centerTitle: true,
              title: const Text(
                "My Tasks",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: const Center(
              child: Text(
                "No Task Avaliable",
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        } else {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: showalertdialog,
              child: const Icon(
                Icons.add,
              ),
            ),
            appBar: AppBar(
              centerTitle: true,
              title: const Text(
                "My Tasks",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: myitems.map((e) => TodoCard(e['id'])).toList(),
              ),
            ),
          );
        }
      },
      error: (_, __) => const Center(
        child: Text(
          "No Data",
        ),
      ),
      loading: () => const Center(
        child: Text(
          "Loading",
        ),
      ),
    );
  }
}
