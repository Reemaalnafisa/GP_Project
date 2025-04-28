import 'package:gat_helper_app/const/data/bar_graph_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gat_helper_app/model/BarGraphModel.dart';
import '../../../const/data/bar_graph_data.dart';

class BarGraphCard extends StatelessWidget {
  const BarGraphCard({super.key});

  @override
  Widget build(BuildContext context) {
    final barGraphData = BarGraphData();
    debugPrint('BarGraph Data: ${barGraphData.data}'); // طباعة البيانات في الـ console

    return GridView.builder(
      itemCount: barGraphData.data.length,
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,  // استخدام عمود واحد لعرض الرسم البياني
        crossAxisSpacing: 3,
        mainAxisSpacing: 6.0,
        childAspectRatio: 1.5 / 0.75,  // جعل الرسم البياني أكثر طولًا
      ),
      itemBuilder: (context, index) {
        return Container(
          width: 150, // تصغير العرض
          height: 90, // تصغير الارتفاع
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            color: Colors.white, // خلفية بيضاء
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 4,
                offset: Offset(0, 2), // تأثير الظل
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0), // تقليل padding لتوفير المساحة
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    barGraphData.data[index].label,
                    style: const TextStyle(
                      fontSize: 18,  // تقليل حجم النص
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 8), // تقليل المسافة بين العناصر
                Flexible(
                  child: BarChart(
                    BarChartData(
                      barGroups: _chartGroups(
                        points: barGraphData.data[index].graph,
                        color: barGraphData.data[index].color,
                      ),
                      borderData: FlBorderData(border: const Border()),
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  barGraphData.label[value.toInt()],
                                  style: const TextStyle(
                                      fontSize: 10, // تقليل حجم النص
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<BarChartGroupData> _chartGroups(
      {required List<GraphModel> points, required Color color}) {
    return points
        .map((point) => BarChartGroupData(x: point.x.toInt(), barRods: [
      BarChartRodData(
        toY: point.y,
        width: 9,  // تقليل عرض الأشرطة
        color: _getBarColor(point.y),  // استخدام ألوان ديناميكية للأشرطة
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(3.0),
          topRight: Radius.circular(3.0),
        ),
      )
    ]))
        .toList();
  }

  Color _getBarColor(double value) {
    if (value < 3) {
      return Colors.red.withOpacity(0.6);  // لون أحمر عندما تكون القيمة منخفضة
    } else if (value < 6) {
      return Colors.yellow.withOpacity(0.7);  // لون أصفر للقيم المتوسطة
    } else {
      return Colors.green.withOpacity(0.8);  // لون أخضر للقيم المرتفعة
    }
  }
}


