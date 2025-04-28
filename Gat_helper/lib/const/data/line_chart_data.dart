import 'package:fl_chart/fl_chart.dart';

class LineData {
  /// ✅ قائمة الأشهر
  final List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"];

  /// ✅ بيانات لكل شهر
  final Map<String, List<FlSpot>> spots1 = {
    "Jan": [FlSpot(1, 20), FlSpot(2, 25), FlSpot(20, 40)],
    "Feb": [FlSpot(1, 15), FlSpot(2, 20), FlSpot(3, 35)],
    "Mar": [FlSpot(1, 10), FlSpot(2, 18), FlSpot(3, 25)],
    "Apr": [FlSpot(1, 5), FlSpot(2, 22), FlSpot(3, 40)],
    "May": [FlSpot(1, 8), FlSpot(2, 28), FlSpot(3, 34)],
    "Jun": [FlSpot(1, 12), FlSpot(2, 30), FlSpot(3, 45)],
  };

  final Map<String, List<FlSpot>> spots2 = {
    "Jan": [FlSpot(1, 18), FlSpot(2, 22), FlSpot(3, 28)],
    "Feb": [FlSpot(1, 12), FlSpot(2, 19), FlSpot(3, 27)],
    "Mar": [FlSpot(1, 14), FlSpot(2, 16), FlSpot(3, 24)],
    "Apr": [FlSpot(1, 7), FlSpot(2, 20), FlSpot(3, 38)],
    "May": [FlSpot(1, 10), FlSpot(2, 24), FlSpot(3, 42)],
    "Jun": [FlSpot(1, 11), FlSpot(2, 26), FlSpot(3, 40)],
  };

  /// ✅ الأرقام في المحور X (من 1 إلى 100)
  final bottomTitle = {
    1: '1',
    10: '10',
    20: '20',
    30: '30',
    40: '40',
    50: '50',

  };
}

