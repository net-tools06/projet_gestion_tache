import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'screen/TodoListScreen.dart';

// Point d'entrée principal de l'application
void main() {
  runApp(MyApp());
}

// Widget principal de l'application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: MaterialApp(
        title: 'Todo App',
        home: TaskScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          FilteredTasksScreen.routeName: (context) => FilteredTasksScreen(),
          AddTaskScreen.routeName: (context) => AddTaskScreen(),
          EditTaskScreen.routeName: (context) => EditTaskScreen(),
        },
      ),
    );
  }
}

// Fournisseur de tâches qui gère l'état des tâches
class TaskProvider with ChangeNotifier {
  // Liste de tâches initiale
  List<Task> _tasks = [
    Task(name: 'Task 1', status: 'Todo'),
    Task(name: 'Task 2', status: 'In progress'),
    Task(name: 'Task 3', status: 'Bug'),
    Task(name: 'Task 4', status: 'Bug'),
    Task(name: 'Task 5', status: 'Todo'),
    Task(name: 'Task 6', status: 'Todo'),
    Task(name: 'Task 7', status: 'Done'),
  ];

  // Liste filtrée des tâches
  List<Task> _filteredTasks = [];

  // Accesseurs pour obtenir les listes de tâches
  List<Task> get tasks => _tasks;
  List<Task> get filteredTasks => _filteredTasks;

  // Méthode pour ajouter une tâche
  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  // Méthode pour mettre à jour une tâche existante
  void updateTask(int index, Task task) {
    _tasks[index] = task;
    notifyListeners();
  }

  // Méthode pour appliquer des filtres sur les tâches
  void applyFilters(List<String> filters) {
    _filteredTasks = _tasks.where((task) => filters.contains(task.status)).toList();
    notifyListeners();
  }
}

// Modèle de tâche avec gestion de la couleur en fonction du statut
class Task {
  String name;
  String status;
  String description;

  Task({required this.name, required this.status, this.description = ''}) {
    _updateColor();
  }

  // Propriété pour obtenir la couleur en fonction du statut
  Color get color {
    switch (status) {
      case 'Todo':
        return Colors.grey;
      case 'In progress':
        return Colors.green;
      case 'Done':
        return Colors.lightBlue;
      case 'Bug':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Méthode pour mettre à jour la couleur (actuellement vide)
  void _updateColor() {
    // Notifier les listeners si nécessaire, ou autres mises à jour.
  }
}

// Écran principal affichant la liste des tâches
class TaskScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => FilterDialog(),
              );
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return TaskList(taskProvider: taskProvider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AddTaskScreen.routeName).then((value) {
            Provider.of<TaskProvider>(context, listen: false).notifyListeners();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

// Widget pour afficher la liste des tâches
class TaskList extends StatelessWidget {
  final TaskProvider taskProvider;

  TaskList({required this.taskProvider});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: taskProvider.tasks.length,
      itemBuilder: (context, index) {
        return TaskTile(
          task: taskProvider.tasks[index],
          index: index,
        );
      },
    );
  }
}

// Widget pour afficher une tâche individuelle
class TaskTile extends StatelessWidget {
  final Task task;
  final int index;

  TaskTile({required this.task, required this.index});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: task.color,
      ),
      title: Text(task.name),
      onTap: () {
        Navigator.pushNamed(
          context,
          EditTaskScreen.routeName,
          arguments: {'task': task, 'index': index},
        );
      },
    );
  }
}

// Écran pour éditer une tâche
class EditTaskScreen extends StatefulWidget {
  static const routeName = '/edit-task';

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late Task _task;
  late int _index;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _task = args['task'];
    _index = args['index'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier Tâche'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Modifier',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _task.status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: <String>['Todo', 'In progress', 'Done', 'Bug']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _task.status = newValue!;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _task.name,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onSaved: (newValue) {
                  _task.name = newValue!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _task.description,
                maxLines: 6,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onSaved: (newValue) {
                  _task.description = newValue!;
                },
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Mettre à jour la couleur de la tâche en fonction du nouveau statut
                      _task._updateColor();
                      Provider.of<TaskProvider>(context, listen: false).updateTask(_index, _task);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Modifier'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Boîte de dialogue pour filtrer les tâches
class FilterDialog extends StatefulWidget {
  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  final List<String> _filters = ['Todo', 'In progress', 'Done', 'Bug'];
  final Map<String, bool> _filterSelection = {
    'Todo': false,
    'In progress': false,
    'Done': false,
    'Bug': false,
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filter by'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _filters.map((filter) {
          return CheckboxListTile(
            title: Text(filter),
            value: _filterSelection[filter],
            onChanged: (value) {
              setState(() {
                _filterSelection[filter] = value!;
              });
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            List<String> selectedFilters = _filters.where((filter) => _filterSelection[filter]!).toList();
            Provider.of<TaskProvider>(context, listen: false).applyFilters(selectedFilters);
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(FilteredTasksScreen.routeName);
          },
          child: Text('Apply'),
        ),
      ],
    );
  }
}

// Écran pour afficher les tâches filtrées
class FilteredTasksScreen extends StatelessWidget {
  static const routeName = '/filtered-tasks';

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final filteredTasks = taskProvider.filteredTasks;
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtered Tasks'),
      ),
      body: ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(filteredTasks[index].name),
            leading: CircleAvatar(
              backgroundColor: filteredTasks[index].color,
            ),
          );
        },
      ),
    );
  }
}

// Écran pour ajouter une nouvelle tâche
class AddTaskScreen extends StatefulWidget {
  static const routeName = '/add-task';

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _taskName = '';
  String _taskStatus = 'Todo';
  String _taskDescription = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Task',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _taskStatus,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: <String>['Todo', 'In progress', 'Done', 'Bug']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _taskStatus = newValue!;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onSaved: (newValue) {
                  _taskName = newValue!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                maxLines: 6,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onSaved: (newValue) {
                  _taskDescription = newValue!;
                },
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final newTask = Task(
                        name: _taskName,
                        status: _taskStatus,
                        description: _taskDescription,
                      );
                      Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Add'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
