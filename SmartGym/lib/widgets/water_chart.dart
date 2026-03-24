import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget hiển thị chart với "window" có thể trượt qua 30-day data bằng Slider.
/// - data: List of { "date": "YYYY-MM-DD" or ISO, "total": number }
/// - title: tiêu đề
/// - windowSize: số ngày hiển thị cùng lúc (mặc định 7)
class WaterChartScrollable extends StatefulWidget {
  final List<dynamic> data;
  final String title;
  final int windowSize; // số ngày hiển thị cùng lúc

  const WaterChartScrollable({
    super.key,
    required this.data,
    required this.title,
    this.windowSize = 7,
  });

  @override
  _WaterChartScrollableState createState() => _WaterChartScrollableState();
}

class _WaterChartScrollableState extends State<WaterChartScrollable> {
  late int startIndex; // inclusive
  late int maxStart;

  @override
  void initState() {
    super.initState();
    final len = widget.data.length;
    maxStart = max(0, len - widget.windowSize);
    startIndex = maxStart; // show most recent window by default (right-most)
  }

  @override
  void didUpdateWidget(covariant WaterChartScrollable oldWidget) {
    super.didUpdateWidget(oldWidget);
    final len = widget.data.length;
    maxStart = max(0, len - widget.windowSize);
    if (startIndex > maxStart) startIndex = maxStart;
  }

  @override
  Widget build(BuildContext context) {
    final window = widget.data.sublist(
      startIndex,
      min(startIndex + widget.windowSize, widget.data.length),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            if (widget.data.length > widget.windowSize)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text('${startIndex + 1}-${min(startIndex + widget.windowSize, widget.data.length)}/${widget.data.length}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 240,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
              child: _buildBarChart(window),
            ),
          ),
        ),
        if (widget.data.length > widget.windowSize) ...[
          const SizedBox(height: 8),
          _buildSlider(context),
        ],
      ],
    );
  }

  Widget _buildSlider(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor: Colors.grey[300],
          ),
          child: Slider(
            min: 0,
            max: maxStart.toDouble(),
            value: startIndex.toDouble(),
            divisions: maxStart > 0 ? maxStart : null,
            label: 'Ngày ${startIndex + 1} - ${min(startIndex + widget.windowSize, widget.data.length)}',
            onChanged: (v) {
              setState(() {
                startIndex = v.round();
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Row(
            children: [
              Text('Đầu', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const Spacer(),
              Text('Cuối', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<dynamic> windowData) {
    final totals = windowData.map<double>((e) {
      final v = e['total'];
      if (v is int) return v.toDouble();
      if (v is double) return v;
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }).toList();

    final maxY = _calcMaxY(totals);

    return BarChart(
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
              final item = windowData[idx];
              final date = _parseDate(item['date']);
              final label = DateFormat('EEE, d MMM').format(date);
              return BarTooltipItem('$label\n${rod.toY.toInt()} ml', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY / 4,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= windowData.length) return const SizedBox.shrink();
                final date = _parseDate(windowData[idx]['date']);
                final label = windowData.length > 7 ? DateFormat('d/M').format(date) : DateFormat('E').format(date);
                return Padding(padding: const EdgeInsets.only(top: 6.0), child: Text(label, style: const TextStyle(fontSize: 11)));
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(windowData.length, (i) {
          final val = totals[i];
          final gradient = [Colors.blue.shade300, Colors.blue.shade700];
          return BarChartGroupData(
            x: i,
            barsSpace: 4,
            barRods: [
              BarChartRodData(
                toY: val,
                width: 18,
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(colors: gradient, begin: Alignment.bottomCenter, end: Alignment.topCenter),
                backDrawRodData: BackgroundBarChartRodData(show: true, toY: maxY, color: Colors.grey.shade100),
              ),
            ],
          );
        }),
      ),
      swapAnimationDuration: const Duration(milliseconds: 400),
      swapAnimationCurve: Curves.easeOutCubic,
    );
  }

  static DateTime _parseDate(dynamic raw) {
    try {
      if (raw is DateTime) return raw;
      if (raw is String) {
        if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)) return DateTime.parse(raw);
        return DateTime.parse(raw);
      }
    } catch (_) {}
    return DateTime.now();
  }

  double _calcMaxY(List<double> totals) {
    final maxVal = totals.isEmpty ? 100.0 : totals.reduce(max);
    final padded = max(100.0, maxVal * 1.2);
    final step = padded <= 1000 ? 100 : 200;
    return ((padded / step).ceil() * step).toDouble();
  }
}

/// Wrapper giữ tên cũ WaterChart để tương thích với chỗ gọi hiện tại.
/// Sử dụng WaterChart(data: ..., title: ..., windowSize: 7)
class WaterChart extends StatelessWidget {
  final List<dynamic> data;
  final String title;
  final int windowSize;

  const WaterChart({
    super.key,
    required this.data,
    required this.title,
    this.windowSize = 7,
  });

  @override
  Widget build(BuildContext context) {
    return WaterChartScrollable(
      data: data,
      title: title,
      windowSize: min(windowSize, data.length),
    );
  }
}