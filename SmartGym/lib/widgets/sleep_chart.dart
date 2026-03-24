import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SleepChart extends StatefulWidget {
  final List<dynamic> data; // each: { 'date': 'YYYY-MM-DD', 'total': number (minutes) }
  final String title;
  final int windowSize; // number of days visible at once, default 7
  final int nightlyGoal; // in minutes, default 480 (8h)
  final bool showGoalLine;

  const SleepChart({
    super.key,
    required this.data,
    required this.title,
    this.windowSize = 7,
    this.nightlyGoal = 480,
    this.showGoalLine = true,
  });

  @override
  State<SleepChart> createState() => _SleepChartState();
}

class _SleepChartState extends State<SleepChart> {
  late int startIndex;
  late int maxStart;
  late List<Map<String, dynamic>> _fullSeries; // padded, ordered ascending by date
  double _accumulatedDrag = 0.0;

  @override
  void initState() {
    super.initState();
    _buildFullSeries();
    maxStart = max(0, _fullSeries.length - widget.windowSize);
    startIndex = maxStart;
  }

  @override
  void didUpdateWidget(covariant SleepChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _buildFullSeries();
    final len = _fullSeries.length;
    maxStart = max(0, len - widget.windowSize);
    if (startIndex > maxStart) startIndex = maxStart;
  }

  void _buildFullSeries() {
    final Map<String, Map<String, dynamic>> map = {};
    for (var e in widget.data) {
      try {
        final d = _parseDate(e['date']);
        final key = DateFormat('yyyy-MM-dd').format(d);
        final total = e['total'] ?? e['totalMinutes'] ?? 0;
        final val = (total is num) ? total.toDouble() : double.tryParse(total.toString()) ?? 0.0;
        map[key] = {'date': key, 'total': val};
      } catch (_) {
        // skip malformed
      }
    }

    final today = DateTime.now();
    DateTime startDay;
    if (map.isNotEmpty) {
      final keys = map.keys.toList()..sort();
      final earliest = DateTime.parse(keys.first);
      final minStart = today.subtract(Duration(days: widget.windowSize - 1));
      startDay = earliest.isBefore(minStart) ? earliest : minStart;
    } else {
      startDay = today.subtract(Duration(days: widget.windowSize - 1));
    }

    DateTime endDay;
    if (map.isNotEmpty) {
      final keys = map.keys.toList()..sort();
      final latest = DateTime.parse(keys.last);
      endDay = latest.isAfter(today) ? latest : today;
    } else {
      endDay = today;
    }

    final spanDays = endDay.difference(startDay).inDays + 1;
    if (spanDays < widget.windowSize) {
      startDay = endDay.subtract(Duration(days: widget.windowSize - 1));
    }

    final List<Map<String, dynamic>> out = [];
    final totalDays = endDay.difference(startDay).inDays + 1;
    for (int i = 0; i < totalDays; i++) {
      final d = startDay.add(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(d);
      if (map.containsKey(key)) out.add(map[key]!);
      else out.add({'date': key, 'total': 0.0});
    }

    _fullSeries = out;
  }

  List<Map<String, dynamic>> _windowData() {
    final end = min(startIndex + widget.windowSize, _fullSeries.length);
    return _fullSeries.sublist(startIndex, end);
  }

  double _calcMaxY(List<double> vals) {
    final maxVal = vals.isEmpty ? (widget.nightlyGoal.toDouble()) : vals.reduce(max);
    final padded = max(maxVal, widget.nightlyGoal.toDouble()) * 1.2;
    final step = padded <= 120 ? 30 : (padded <= 300 ? 60 : 120);
    return ((padded / step).ceil() * step).toDouble();
  }

  DateTime _parseDate(dynamic raw) {
    try {
      if (raw is DateTime) return raw;
      if (raw is String) return DateTime.parse(raw);
      return DateTime.parse(raw.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  String _formatTooltipMinutes(double minutes) {
    final m = minutes.toInt();
    final h = m ~/ 60;
    final mm = m % 60;
    if (h > 0) return '${h}h ${mm}m';
    return '${mm}m';
  }

  // helper to clamp and set startIndex once (avoid frequent setState)
  void _setStartIndex(int i) {
    final bounded = i.clamp(0, maxStart);
    if (bounded != startIndex) setState(() => startIndex = bounded);
  }

  @override
  Widget build(BuildContext context) {
    final window = _windowData();
    final totals = window.map<double>((e) {
      final v = e['total'] ?? e['totalMinutes'] ?? 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }).toList();

    final maxY = _calcMaxY(totals);
    final goalY = widget.nightlyGoal.toDouble();

    // estimate pixels per item for drag-to-scroll mapping
    final barAreaWidth = MediaQuery.of(context).size.width - 64; // padding estimate
    final pixelsPerItem = (barAreaWidth / (widget.windowSize > 0 ? widget.windowSize : 7)).clamp(12.0, 60.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(child: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          if (_fullSeries.length > widget.windowSize)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text('${startIndex + 1}-${min(startIndex + widget.windowSize, _fullSeries.length)}/${_fullSeries.length}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ),
        ]),
        const SizedBox(height: 8),
        // GestureDetector enables pan-to-scroll horizontally on the chart area
        GestureDetector(
          onHorizontalDragStart: (_) {
            _accumulatedDrag = 0.0;
          },
          onHorizontalDragUpdate: (details) {
            _accumulatedDrag += details.delta.dx;
            final deltaIndex = -(_accumulatedDrag / pixelsPerItem);
            final newIndex = (startIndex + deltaIndex).round();
            final bounded = newIndex.clamp(0, maxStart);
            if (bounded != startIndex) {
              setState(() {
                startIndex = bounded;
                _accumulatedDrag = 0.0; // reset after applying
              });
            }
          },
          child: SizedBox(
            height: 240,
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    alignment: BarChartAlignment.spaceAround,
                    groupsSpace: 12,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.black87,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final idx = group.x.toInt();
                          if (idx < 0 || idx >= window.length) return null;
                          final item = window[idx];
                          final date = _parseDate(item['date']);
                          final label = DateFormat('EEE, d MMM').format(date);
                          return BarTooltipItem(
                            '$label\n${_formatTooltipMinutes(rod.toY)}',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      horizontalInterval: maxY > 0 ? maxY / 4 : widget.nightlyGoal.toDouble() / 4,
                      getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: maxY > 0 ? maxY / 4 : widget.nightlyGoal.toDouble() / 4,
                          reservedSize: 44,
                          getTitlesWidget: (value, meta) {
                            final minutes = value.toInt();
                            final h = minutes ~/ 60;
                            return Text('${h}h', style: TextStyle(color: Colors.grey[700], fontSize: 12));
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= window.length) return const SizedBox.shrink();
                            final date = _parseDate(window[idx]['date']);
                            final label = window.length > 7 ? DateFormat('d/M').format(date) : DateFormat('E').format(date);
                            return Padding(padding: const EdgeInsets.only(top: 6.0), child: Text(label, style: const TextStyle(fontSize: 11)));
                          },
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    extraLinesData: ExtraLinesData(
                      horizontalLines: widget.showGoalLine
                          ? [
                        HorizontalLine(
                          y: goalY,
                          color: Colors.green.shade600,
                          strokeWidth: 2,
                          dashArray: [6, 4],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.only(right: 8),
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            labelResolver: (h) => 'Goal ${ (goalY / 60).toStringAsFixed(1) }h',
                          ),
                        )
                      ]
                          : [],
                    ),
                    barGroups: List.generate(window.length, (i) {
                      final val = totals[i];
                      final reached = widget.showGoalLine ? val >= goalY : false;
                      final colors = reached ? [Colors.green.shade300, Colors.green.shade700] : [Colors.blue.shade300, Colors.blue.shade700];
                      return BarChartGroupData(
                        x: i,
                        barsSpace: 4,
                        barRods: [
                          BarChartRodData(
                            toY: val,
                            width: 18,
                            borderRadius: BorderRadius.circular(6),
                            gradient: LinearGradient(colors: colors, begin: Alignment.bottomCenter, end: Alignment.topCenter),
                            backDrawRodData: BackgroundBarChartRodData(show: true, toY: maxY, color: Colors.grey.shade100),
                          )
                        ],
                      );
                    }),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 200),
                  swapAnimationCurve: Curves.easeOutCubic,
                ),
              ),
            ),
          ),
        ),
        if (_fullSeries.length > widget.windowSize) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: startIndex > 0 ? () => _setStartIndex(max(0, startIndex - widget.windowSize)) : null,
              ),
              Expanded(
                child: Slider(
                  min: 0,
                  max: maxStart.toDouble(),
                  value: startIndex.toDouble(),
                  divisions: maxStart > 0 ? maxStart : null,
                  label: '${startIndex + 1}-${min(startIndex + widget.windowSize, _fullSeries.length)}',
                  onChanged: (v) => _setStartIndex(v.round()),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: startIndex < maxStart ? () => _setStartIndex(min(maxStart, startIndex + widget.windowSize)) : null,
              ),
            ],
          ),
        ],
      ],
    );
  }
}