import 'package:flutter/material.dart';
import 'package:todoapp/model/todo.dart';
import 'package:todoapp/util/dbhelper.dart';
import 'package:intl/intl.dart';

DBHelper dbHelper = DBHelper();
final List<String> choices = const <String>[
  'Save Todo & Back',
  'Delete Todo',
  'Back to List'
];

const menuSave = 'Save Todo & Back';
const menuDelete = 'Delete Todo';
const menuBack = 'Back to List';

class TodoDetail extends StatefulWidget {
  final Todo todo;

  TodoDetail(this.todo);

  @override
  State<StatefulWidget> createState() => TodoDetailState(todo);
}

class TodoDetailState extends State {
  Todo todo;
  final _priorities = ["High", "Medium", "Low"];
  String _priority = "Low";

  TodoDetailState(this.todo);

  TextEditingController titleController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    titleController.text = todo.title;
    descriptionController.text = todo.description;
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(todo.title),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: select,
            itemBuilder: (BuildContext context) {
              return choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Padding(
          padding: EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
          child: Column(
            children: <Widget>[
              getTextField(),
              Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: descriptionController,
                    style: textStyle,
                    onChanged: (value) => this.updateDescription(),
                    decoration: InputDecoration(
                        labelText: "Description",
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  )),
              DropdownButton<String>(
                items: _priorities.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                value: retrivePriority(todo.priority),
                onChanged: (value) => updatePriority(value),
              )
            ],
          )),
    );
  }

  void select(String value) async {
    int result;
    switch (value) {
      case menuSave:
        save();
        break;

      case menuDelete:
        Navigator.pop(context, true);
        if (todo.id == null) {
          return;
        }
        result = await dbHelper.deleteToDo(todo.id);
        if (result != 0) {
          AlertDialog alertDialog = AlertDialog(
            title: Text("Delete Todo"),
            content: Text("The content has been deleted"),
          );
          showDialog(context: context, builder: (_) => alertDialog);
        }
        break;

      case menuBack:
        Navigator.pop(context, true);
        break;
    }
  }

  void save() {
    todo.date = new DateFormat.yMd().format(DateTime.now());
    if (todo.id != null) {
      dbHelper.updateToDo(todo);
    } else {
      dbHelper.insertToDo(todo);
    }
    Navigator.pop(context, true);
  }

  void updatePriority(String value) {
    switch (value) {
      case "High":
        todo.priority = 1;
        break;

      case "Medium":
        todo.priority = 2;
        break;

      case "Low":
        todo.priority = 3;
        break;
    }

    setState(() {
      _priority = value;
    });
  }

  String retrivePriority(int value) {
    return _priorities[value - 1];
  }

  void updateTitle() {
    todo.title = titleController.text;
  }

  void updateDescription() {
    todo.description = descriptionController.text;
  }

  TextField getTextField() {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return TextField(
      controller: titleController,
      style: textStyle,
      onChanged: (value) => this.updateTitle(),
      decoration: InputDecoration(
          labelText: "Text",
          labelStyle: textStyle,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
    );
  }
}
