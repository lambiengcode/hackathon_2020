import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const chartLabelsTextStyle = TextStyle(
  color: Colors.grey,
  fontSize: 14.0,
  fontWeight: FontWeight.w500,
);

class PieChart extends StatelessWidget {
  final List<double> files;

  const PieChart({@required this.files});

  @override
  Widget build(BuildContext context) {
    DateFormat format = new DateFormat('MMM dd');
    final _size = MediaQuery.of(context).size;

    return Container(
      height: _size.height * .3,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: _size.width * .88,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 16.0,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: SideTitles(
                    margin: 10.0,
                    showTitles: true,
                    textStyle: chartLabelsTextStyle,
                    rotateAngle: 35.0,
                    getTitles: (double value) {
                      switch (value.toInt()) {
                        case 0:
                          return format.format(
                              DateTime.now().subtract(new Duration(days: 6)));
                        case 1:
                          return format.format(
                              DateTime.now().subtract(new Duration(days: 5)));
                        case 2:
                          return format.format(
                              DateTime.now().subtract(new Duration(days: 4)));
                        case 3:
                          return format.format(
                              DateTime.now().subtract(new Duration(days: 3)));
                        case 4:
                          return format.format(
                              DateTime.now().subtract(new Duration(days: 2)));
                        case 5:
                          return format.format(
                              DateTime.now().subtract(new Duration(days: 1)));
                        case 6:
                          return format.format(DateTime.now());
                        default:
                          return '';
                      }
                    },
                  ),
                  leftTitles: SideTitles(
                      margin: 10.0,
                      showTitles: true,
                      textStyle: chartLabelsTextStyle,
                      getTitles: (value) {
                        if (value == 0) {
                          return '0';
                        } else if (value % 3 == 0) {
                          return '${value ~/ 3 * 5}';
                        }
                        return '';
                      }),
                ),
                gridData: FlGridData(
                  show: true,
                  checkToShowHorizontalLine: (value) => value % 3 == 0,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.black12,
                    strokeWidth: 1.2,
                    dashArray: [4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: files
                    .asMap()
                    .map((key, value) => MapEntry(
                        key,
                        BarChartGroupData(
                          x: key,
                          barRods: [
                            BarChartRodData(
                              y: value / (5 / 3),
                              color: Colors.red,
                            ),
                          ],
                        )))
                    .values
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
