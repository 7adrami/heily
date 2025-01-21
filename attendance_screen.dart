
// lib/screens/attendance_screen.dart
import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/absence.dart';
import '../services/api_service.dart';

class AttendanceScreen extends StatefulWidget {
  final Student student;

  const AttendanceScreen({Key? key, required this.student}) : super(key: key);

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _apiService = ApiService();
  Map<String, List<Absence>> _groupedAbsences = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAbsences();
  }

  Future<void> _loadAbsences() async {
    try {
      final data = await _apiService.getStudentAbsences(widget.student.matricule);
      final absences = data['absences'] as List<Absence>;

      setState(() {
        _groupedAbsences = {};
        for (var absence in absences) {
          if (!_groupedAbsences.containsKey(absence.week)) {
            _groupedAbsences[absence.week] = [];
          }
          _groupedAbsences[absence.week]!.add(absence);
        }
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load absences: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAbsences,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      widget.student.nomPrenom,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      'Matricule: ${widget.student.matricule}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _groupedAbsences.isEmpty
                ? const Center(
              child: Text('No absences recorded'),
            )
                : ListView.builder(
              itemCount: _groupedAbsences.length,
              itemBuilder: (context, index) {
                final week = _groupedAbsences.keys.elementAt(index);
                final absences = _groupedAbsences[week]!;
                return ExpansionTile(
                  title: Text('Week $week'),
                  children: absences.map((absence) {
                    return ListTile(
                      title: Text('Course: ${absence.courseCode}'),
                      subtitle: Text('Day: ${absence.day}'),
                      leading: const Icon(Icons.calendar_today),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}