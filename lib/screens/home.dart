import 'package:flutter/material.dart';
import 'package:todo_list/models/db.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController txt = TextEditingController();

  final db = Databasehelper.instance;
  String? editval;
  String? errtext;
  bool validated = true;
  var myitems = [];
  List<Widget> children = <Widget>[];

  void addtodo() async {
    Map<String, dynamic> row = {
      Databasehelper.columnName: editval,
    };
    final id = await db.insert(row);
    Navigator.pop(context);
    editval = "";
    setState(() {
      validated = true;
      errtext = "";
    });
  }

  Future<bool> query() async {
    var allrows = await db.queryall();
    for (var row in allrows) {
      myitems.add(row.toString());
      children.add(Card(
        elevation: 5.0,
        margin: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 5.0,
        ),
        child: Container(
          padding: const EdgeInsets.all(5.0),
          child: ListTile(
            title: Text(
              row['todo'],
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            trailing: InkWell(
                onTap: () {
                  db.deletedata(row['id']).then((_) => setState(() {
                        myitems.remove(row.toString());
                      }));
                },
                child: const Icon(Icons.delete)),
          ),
        ),
      ));
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snap) {
        if (snap.hasData == null) {
          return const Center(
            child: Text(
              "No Data",
            ),
          );
        } else {
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
                  children: children,
                ),
              ),
            );
          }
        }
      },
      future: query(),
    );
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
                            child: const Text("ADD",
                                style: TextStyle(
                                  fontSize: 18.0,
                                )),
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
}
