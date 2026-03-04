import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const PillIntakeApp());
}

class PillIntakeApp extends StatelessWidget {
  const PillIntakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pill Intake Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A4E9F)),
        useMaterial3: true,
      ),
      home: const IntakeHomePage(),
    );
  }
}

class IntakeDay {
  const IntakeDay({
    required this.day,
    required this.frequencyLabel,
    required this.doses,
    this.allowEitherSingleOrDouble = false,
  });

  final int day;
  final String frequencyLabel;
  final int doses;
  final bool allowEitherSingleOrDouble;
}

const List<IntakeDay> treatmentPlan = [
  IntakeDay(day: 1, frequencyLabel: 'Every 2h', doses: 6),
  IntakeDay(day: 2, frequencyLabel: 'Every 2h', doses: 6),
  IntakeDay(day: 3, frequencyLabel: 'Every 2h', doses: 6),
  IntakeDay(day: 4, frequencyLabel: 'Every 2.5h', doses: 5),
  IntakeDay(day: 5, frequencyLabel: 'Every 2.5h', doses: 5),
  IntakeDay(day: 6, frequencyLabel: 'Every 2.5h', doses: 5),
  IntakeDay(day: 7, frequencyLabel: 'Every 2.5h', doses: 5),
  IntakeDay(day: 8, frequencyLabel: 'Every 2.5h', doses: 5),
  IntakeDay(day: 9, frequencyLabel: 'Every 2.5h', doses: 5),
  IntakeDay(day: 10, frequencyLabel: 'Every 2.5h', doses: 5),
  IntakeDay(day: 11, frequencyLabel: 'Every 2.5h', doses: 5),
  IntakeDay(day: 12, frequencyLabel: 'Every 2.5h', doses: 5),
  IntakeDay(day: 13, frequencyLabel: 'Every 3h', doses: 4),
  IntakeDay(day: 14, frequencyLabel: 'Every 3h', doses: 4),
  IntakeDay(day: 15, frequencyLabel: 'Every 3h', doses: 4),
  IntakeDay(day: 16, frequencyLabel: 'Every 3h', doses: 4),
  IntakeDay(day: 17, frequencyLabel: 'Every 5h', doses: 3),
  IntakeDay(day: 18, frequencyLabel: 'Every 5h', doses: 3),
  IntakeDay(day: 19, frequencyLabel: 'Every 5h', doses: 3),
  IntakeDay(day: 20, frequencyLabel: 'Every 5h', doses: 3),
  IntakeDay(
    day: 21,
    frequencyLabel: 'Per day',
    doses: 2,
    allowEitherSingleOrDouble: true,
  ),
  IntakeDay(
    day: 22,
    frequencyLabel: 'Per day',
    doses: 2,
    allowEitherSingleOrDouble: true,
  ),
  IntakeDay(
    day: 23,
    frequencyLabel: 'Per day',
    doses: 2,
    allowEitherSingleOrDouble: true,
  ),
  IntakeDay(
    day: 24,
    frequencyLabel: 'Per day',
    doses: 2,
    allowEitherSingleOrDouble: true,
  ),
  IntakeDay(
    day: 25,
    frequencyLabel: 'Per day',
    doses: 2,
    allowEitherSingleOrDouble: true,
  ),
];

class IntakeHomePage extends StatefulWidget {
  const IntakeHomePage({super.key});

  @override
  State<IntakeHomePage> createState() => _IntakeHomePageState();
}

class _IntakeHomePageState extends State<IntakeHomePage> {
  static const String _storageKey = 'intake_state_v1';

  final TextEditingController _nameController = TextEditingController();
  DateTime? _startDate;
  late Map<int, List<bool>> _doseChecks;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _doseChecks = {
      for (final d in treatmentPlan)
        d.day: List<bool>.filled(d.allowEitherSingleOrDouble ? 3 : d.doses, false),
    };
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null) {
      setState(() => _loading = false);
      return;
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _nameController.text = decoded['name'] as String? ?? '';

    final startDateRaw = decoded['startDate'] as String?;
    if (startDateRaw != null && startDateRaw.isNotEmpty) {
      _startDate = DateTime.tryParse(startDateRaw);
    }

    final doseData = decoded['checks'] as Map<String, dynamic>?;
    if (doseData != null) {
      for (final entry in doseData.entries) {
        final day = int.tryParse(entry.key);
        final values = entry.value;
        if (day != null && values is List && _doseChecks.containsKey(day)) {
          final target = _doseChecks[day]!;
          for (var i = 0; i < target.length && i < values.length; i++) {
            if (values[i] is bool) {
              target[i] = values[i] as bool;
            }
          }
        }
      }
    }

    setState(() => _loading = false);
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'name': _nameController.text.trim(),
      'startDate': _startDate?.toIso8601String(),
      'checks': _doseChecks.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
    };
    await prefs.setString(_storageKey, jsonEncode(payload));
  }

  int get _completedDoses =>
      _doseChecks.values.expand((e) => e).where((done) => done).length;

  int get _totalDoses => _doseChecks.values.expand((e) => e).length;

  Future<void> _selectStartDate() async {
    final now = DateTime.now();
    final chosen = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      initialDate: _startDate ?? now,
    );

    if (chosen != null) {
      setState(() => _startDate = chosen);
      _saveState();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('25-day Pill Intake Plan'),
        actions: [
          IconButton(
            tooltip: 'Reset all',
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              for (final day in _doseChecks.keys) {
                _doseChecks[day] = List<bool>.filled(_doseChecks[day]!.length, false);
              }
              setState(() {});
              await _saveState();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Patient name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _saveState(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _startDate == null
                              ? 'Start date: not set'
                              : 'Start date: ${DateFormat('yyyy-MM-dd').format(_startDate!)}',
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _selectStartDate,
                        icon: const Icon(Icons.calendar_month),
                        label: const Text('Select'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _totalDoses == 0 ? 0 : _completedDoses / _totalDoses,
                  ),
                  const SizedBox(height: 4),
                  Text('$_completedDoses / $_totalDoses doses tracked'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...treatmentPlan.map(_buildDayCard),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Tip: You can add local notifications later using flutter_local_notifications '
                'to alert each next dose time.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(IntakeDay day) {
    final checks = _doseChecks[day.day]!;
    final complete = checks.where((v) => v).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Day ${day.day} • ${day.frequencyLabel}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text('Completed: $complete/${checks.length}'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(checks.length, (index) {
                final label = day.allowEitherSingleOrDouble
                    ? (index == 0 ? '1 pill' : 'Option ${index}')
                    : 'Dose ${index + 1}';
                return FilterChip(
                  selected: checks[index],
                  label: Text(label),
                  onSelected: (selected) {
                    setState(() {
                      if (day.allowEitherSingleOrDouble) {
                        // For "1 pill or 2 pills" style days from the leaflet,
                        // keep options mutually exclusive among first two pills.
                        if (index == 0 && selected) {
                          checks[1] = false;
                          checks[2] = false;
                        }
                        if ((index == 1 || index == 2) && selected) {
                          checks[0] = false;
                        }
                      }
                      checks[index] = selected;
                    });
                    _saveState();
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
