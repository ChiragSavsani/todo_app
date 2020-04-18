import 'package:flutter/material.dart';
import 'package:todoapp/model/todo.dart';
import 'package:todoapp/util/dbhelper.dart';
import 'package:todoapp/screens/tododetail.dart';

class ToDoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ToDoListState();
}

class ToDoListState extends State {
  DBHelper helper = new DBHelper();
  List<Todo> todoList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (todoList == null) {
      todoList = List<Todo>();
      getData();
    }
    return Scaffold(
      body: todosListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Todo('', 3, ''));
        },
        tooltip: "Add New Todo",
        child: Icon(Icons.add),
      ),
    );
  }

  ListView todosListView() {
    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getColor(this.todoList[position].priority),
                child: Text(this.todoList[position].priority.toString()),
              ),
              title: Text(this.todoList[position].title),
              subtitle: Text(this.todoList[position].date),
              onTap: () {
                debugPrint("Tapped on" + this.todoList[position].id.toString());
                navigateToDetail(this.todoList[position]);
              },
            ),
          );
        });
  }

  void getData() {
    final dbFuture = helper.initializeDb();
    dbFuture.then((result) {
      final todosFuture = helper.getToDos();
      todosFuture.then((result) {
        List<Todo> todos = List<Todo>();
        count = result.length;
        for (int i = 0; i < count; i++) {
          todos.add(Todo.fromObject(result[i]));
          debugPrint(todos[i].title);
        }
        setState(() {
          todoList = todos;
          count = count;
        });
        debugPrint("Items " + count.toString());
      });
    });
  }

  Color getColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.orange;
        break;
      case 3:
        return Colors.green;
        break;

      default:
        return Colors.green;
    }
  }

  void navigateToDetail(Todo todo) async {
    bool result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => TodoDetail(todo)));

    if (result == true) {
      getData();
    }
  }
}
