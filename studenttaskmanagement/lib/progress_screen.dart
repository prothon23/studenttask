import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'task_model.dart';
import 'db_helper.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final DBHelper dbHelper = DBHelper();
  int completed = 0;
  int incomplete = 0;

  @override
  void initState() {
    super.initState();
    _loadTaskStats();
  }

  Future<void> _loadTaskStats() async {
    final tasks = await dbHelper.getTasks();
    setState(() {
      completed = tasks.where((t) => t.isCompleted).length;
      incomplete = tasks.where((t) => !t.isCompleted).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = completed + incomplete;
    return Scaffold(
      appBar: AppBar(title: const Text("Progress Tracker")),
      body: total == 0
          ? const Center(child: Text("No tasks to show."))
          : SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  sections: [
                    PieChartSectionData(
                      value: completed.toDouble(),
                      title: "Done",
                      color: Colors.green,
                      titleStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: incomplete.toDouble(),
                      title: "Pending",
                      color: Colors.redAccent,
                      titleStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text("Completed: $completed"),
            Text("Pending: $incomplete"),
          ],
        ),
      ),
    );
  }
}
