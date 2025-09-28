// statistics_screen.dart
// Statistics & Charts UI for Income/Expense analysis
// Updated: 2025-06-03 – align with Riverpod TaskProvider

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/task_provider.dart'; // Riverpod provider
import '../models/task_model.dart';

/// Enum to switch between pie chart and bar chart
enum ChartType { pie, bar }

/// Stateful widget that can read Riverpod providers via [WidgetRef]
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  // Quick-filter presets
  static const List<String> _presetLabels = [
    'Hôm nay',
    'Hôm qua',
    '7 ngày qua',
    '30 ngày qua',
    'Tùy chọn…',
  ];

  DateTimeRange _range = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );

  int _selectedPreset = 0; // default "Hôm nay"
  ChartType _chartType = ChartType.pie;
  final DateFormat _dFmt = DateFormat('dd/MM/yyyy');

  // -------------------- Date-range helpers --------------------
  void _setPreset(int index) {
    final now = DateTime.now();
    DateTimeRange newRange;
    switch (index) {
      case 0: // today
        newRange = DateTimeRange(start: now, end: now);
        break;
      case 1: // yesterday
        final y = now.subtract(const Duration(days: 1));
        newRange = DateTimeRange(start: y, end: y);
        break;
      case 2: // last 7 days
        newRange = DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now);
        break;
      case 3: // last 30 days
        newRange = DateTimeRange(start: now.subtract(const Duration(days: 29)), end: now);
        break;
      default:
        newRange = _range; // keep current until user picks
    }
    setState(() {
      _selectedPreset = index;
      _range = newRange;
    });
  }

  Future<void> _pickCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _range,
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null) {
      setState(() {
        _selectedPreset = 4; // custom selected
        _range = picked;
      });
    }
  }

  // -------------------- Data aggregation --------------------
  Map<String, double> _aggregate(List<Task> tasks) {
    double income = 0;
    double expense = 0;

    for (final t in tasks) {
      // Skip tasks outside selected window
      if (t.createdAt.isBefore(_range.start) || t.createdAt.isAfter(_range.end)) continue;

      // NOTE: update these conditions once `Task` model has amount/isExpense fields.
      // For now, treat completed tasks as "expense" and incomplete as "income" as placeholder.
      if (t.isCompleted) {
        expense += 1; // or t.amount when available
      } else {
        income += 1; // or t.amount when available
      }
    }

    return {'Thu nhập': income, 'Chi tiêu': expense};
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskListProvider);
    final data = _aggregate(tasks);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê thu – chi'),
        actions: [
          IconButton(
            tooltip: _chartType == ChartType.pie
                ? 'Chuyển sang biểu đồ cột'
                : 'Chuyển sang biểu đồ tròn',
            icon: Icon(
              _chartType == ChartType.pie ? Icons.bar_chart : Icons.pie_chart,
            ),
            onPressed: () => setState(() {
              _chartType = _chartType == ChartType.pie ? ChartType.bar : ChartType.pie;
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPresetChips(),
          _buildDateRangeCaption(),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _chartType == ChartType.pie
                  ? _buildPieChart(data)
                  : _buildBarChart(data),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Helpers: UI widgets --------------------
  Widget _buildPresetChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: List.generate(_presetLabels.length, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(_presetLabels[i]),
              selected: _selectedPreset == i,
              onSelected: (selected) {
                if (!selected) return;
                if (i == 4) {
                  _pickCustomRange();
                } else {
                  _setPreset(i);
                }
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDateRangeCaption() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: _pickCustomRange,
        child: Text(
          '${_dFmt.format(_range.start)} → ${_dFmt.format(_range.end)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  // -------------------- Charts --------------------
  Widget _buildPieChart(Map<String, double> data) {
    final total = data.values.fold<double>(0, (p, e) => p + e);
    if (total == 0) return _emptyChartPlaceholder();

    final sections = data.entries
        .where((e) => e.value > 0)
        .map((e) {
      final percent = (e.value / total * 100).toStringAsFixed(1);
      return PieChartSectionData(
        value: e.value,
        title: '$percent%',
        radius: 80,
        titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      );
    })
        .toList();

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 40,
        sections: sections,
      ),
    );
  }

  Widget _buildBarChart(Map<String, double> data) {
    if (data.values.every((v) => v == 0)) return _emptyChartPlaceholder();

    final barGroups = data.entries
        .toList(growable: false)
        .asMap()
        .entries
        .map((entry) {
      final idx = entry.key;
      final value = entry.value.value;
      return BarChartGroupData(
        x: idx,
        barRods: [BarChartRodData(toY: value, width: 22)],
        showingTooltipIndicators: [0],
      );
    })
        .toList();

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 42),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double index, TitleMeta meta) {
                final i = index.toInt();
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(data.keys.elementAt(i), style: const TextStyle(fontSize: 12)),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(show: true),
      ),
    );
  }

  Widget _emptyChartPlaceholder() => Center(
    child: Text(
      'Chưa có dữ liệu trong khoảng thời gian này',
      style: Theme.of(context).textTheme.bodyMedium,
    ),
  );
}
