import 'package:flutter/material.dart';
import 'package:sih_prototype/models/uv.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double sliderValue = 0.2, milkQual = 90000;
  DateTime lastAlert = DateTime.now();
  Map seenVals = {};
  List<UV> getData() {
    final List<UV> chartData = [];
    return chartData;
  }

  double getBucket(double value) {
    if (value >= 0.9) {
      return 0.9;
    } else if (value >= 0.8) {
      return 0.8;
    } else if (value >= 0.7) {
      return 0.7;
    } else if (value >= 0.6) {
      return 0.6;
    } else if (value >= 0.5) {
      return 0.5;
    } else if (value >= 0.4) {
      return 0.4;
    } else if (value >= 0.3) {
      return 0.3;
    } else if (value >= 0.2) {
      return 0.2;
    } else if (value >= 0.1) {
      return 0.1;
    } else {
      return 0;
    }
  }

  late final List<UV> _chartData;
  @override
  void initState() {
    _chartData = getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Milk quality: ${milkQual.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.03,
                      color: milkQual <= 150000 && milkQual >= 100000
                          ? Colors.green
                          : Colors.redAccent,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.1,
                    ),
                    child: Divider(
                      height: MediaQuery.of(context).size.width * 0.05,
                      thickness: MediaQuery.of(context).size.height * 0.003,
                    ),
                  ),
                  Text(
                    'UV intensity: ${(sliderValue * 100).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.03,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.08,
                    ),
                    child: Slider(
                      value: sliderValue,
                      onChanged: (value) {
                        setState(
                          () {
                            sliderValue = value;
                            if (sliderValue >= 0.9) {
                              milkQual = 150000;
                            } else if (sliderValue >= 0.7) {
                              milkQual = 130000;
                            } else if (sliderValue >= 0.5) {
                              milkQual = 110000;
                            } else if (sliderValue < 0.5) {
                              milkQual = 90000;
                            }
                            if (milkQual < 100000) {
                              int diff = lastAlert
                                  .difference(DateTime.now())
                                  .inSeconds
                                  .abs();
                              if (diff > 5) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.red,
                                      title: const Center(
                                        child: Text(
                                          'QUALITY GONE DOWN',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      content: const Text(
                                        'Kindly adjust the UV intensity before the milk gets spoiled',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      actions: [
                                        Center(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text(
                                              'Ok',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                Colors.red.shade300,
                                              ),
                                              fixedSize:
                                                  MaterialStateProperty.all(
                                                Size(
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.4,
                                                  MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.04,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                lastAlert = DateTime.now();
                              }
                            }
                            if (!seenVals.containsKey(getBucket(sliderValue)
                                .toStringAsPrecision(1))) {
                              seenVals[getBucket(sliderValue)
                                  .toStringAsPrecision(1)] = true;
                              _chartData.add(
                                UV(
                                  intensity: double.parse(
                                    sliderValue.toStringAsPrecision(1),
                                  ),
                                  threshold: milkQual.toInt(),
                                ),
                              );
                              _chartData.sort((UV el1, UV el2) {
                                return el1.intensity.compareTo(el2.intensity);
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 2,
              child: SfCartesianChart(
                title: ChartTitle(text: 'Milk Quality plot'),
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.06,
                  vertical: MediaQuery.of(context).size.height * 0.05,
                ),
                primaryXAxis: CategoryAxis(
                  title: AxisTitle(text: 'UV Intensity'),
                ),
                primaryYAxis: CategoryAxis(
                  title: AxisTitle(
                    text: 'Somatic cell count',
                  ),
                ),
                series: [
                  BarSeries(
                    dataSource: _chartData,
                    xValueMapper: (UV value, _) => value.intensity,
                    yValueMapper: (UV value, _) => value.threshold,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
