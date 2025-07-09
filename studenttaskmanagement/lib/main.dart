import 'package:flutter/material.dart';
import 'task_model.dart';
import 'db_helper.dart';
import 'add_edit_task.dart';
import 'progress_screen.dart';

void main() {
  runApp(const StudentTaskManagerApp());
}

class StudentTaskManagerApp extends StatelessWidget {
  const StudentTaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DBHelper dbHelper = DBHelper();
  List<Task> tasks = [];
  List<Task> filteredTasks = [];

  String? selectedPriority;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  void loadTasks() async {
    final loadedTasks = await dbHelper.getTasks();
    setState(() {
      tasks = loadedTasks;
      applyFilters();
    });
  }

  void applyFilters() {
    setState(() {
      filteredTasks = tasks.where((task) {
        final matchesPriority =
            selectedPriority == null || task.priority == selectedPriority;
        final matchesCategory =
            selectedCategory == null || task.category == selectedCategory;
        return matchesPriority && matchesCategory;
      }).toList();
    });
  }

  void _deleteTask(int id) async {
    await dbHelper.deleteTask(id);
    loadTasks();
  }

  void _showOptions(Task task) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditTask(task: task),
                ),
              ).then((_) => loadTasks());
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text("Delete"),
            onTap: () {
              Navigator.pop(context);
              _deleteTask(task.id!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(task.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Details: ${task.description}"),
                Text("Priority: ${task.priority}"),
                Text("Category: ${task.category}"),
                Text("Due Date: ${task.dueDate}"),
              ],
            ),
          ),
        );
      },
      onLongPress: () => _showOptions(task),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          title: Text(task.title),
          subtitle: Text('${task.category} - ${task.priority}'),
          trailing: Checkbox(
            value: task.isCompleted,
            onChanged: (val) async {
              task.isCompleted = val ?? false;
              await dbHelper.updateTask(task);
              loadTasks();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedPriority,
              hint: const Text("Priority"),
              items: ['High', 'Medium', 'Low']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedPriority = value;
                  applyFilters();
                });
              },
              isExpanded: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedCategory,
              hint: const Text("Category"),
              items: ['Academic', 'Personal']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                  applyFilters();
                });
              },
              isExpanded: true,
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: "Clear Filters",
            onPressed: () {
              setState(() {
                selectedPriority = null;
                selectedCategory = null;
                applyFilters();
              });
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: Color(0xFFC68EFD),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            "Student Task Manager",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            tooltip: "View Progress",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProgressScreen()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          _buildFilterRow(),
          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(child: Text("No tasks found."))
                : ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (_, index) =>
                  _buildTaskCard(filteredTasks[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditTask()),
          );
          loadTasks();
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
