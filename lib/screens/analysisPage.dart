import 'package:colours/colours.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:virtuetracker/Models/UserInfoModel.dart';
import 'package:virtuetracker/controllers/pieChartController.dart';
import 'package:virtuetracker/controllers/statsController.dart';
import 'package:virtuetracker/screens/gridPage.dart';

import '../App_Configuration/apptheme.dart';
import '../Models/LegalCalendarModel.dart';
import '../Models/ChartDataModel.dart';
import '../widgets/Calendar.dart';
import '../widgets/appBarWidget.dart';

class AnalysisPage extends ConsumerStatefulWidget {
  const AnalysisPage({super.key});

  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends ConsumerState<AnalysisPage> {
  @override
  initState() {
    // TODO: implement initState
    super.initState();
    final userInfo = ref.read(userInfoProviderr);
    String communityName = userInfo.currentCommunity;
    ref
        .read(statsControllerProvider.notifier)
        .getAllStats(communityName.toLowerCase());
    // ref
    //     .read(statsControllerProvider.notifier)
    //     .getQuadrantsUsedList(communityName.toLowerCase());
    // callFunctions(communityName);
    // await ref.read(statsControllerProvider.notifier).buildCalendar();
  }

  void callFunctions(String communityName) {
    ref
        .read(statsControllerProvider.notifier)
        .getQuadrantsUsedList(communityName.toLowerCase());
    ref
        .read(statsControllerProvider.notifier)
        .getAllStats(communityName.toLowerCase());
    // ref.invalidate(statsControllerProvider);

    // ref.read(statsControllerProvider.notifier).buildCalendar();
  }

  List<LegalCalendarModel> calendarData = [];
  Map<String, int>? topThreeVirtues;
  Map<String, int>? bottomThreeVirtues;
  List<ChartData> chartData = [];
  CustomCalender calendar = CustomCalender();
  @override
  Widget build(BuildContext context) {
    ref.watch(statsControllerProvider).when(
        data: (response) {
          if (response != null && response['success'] != null) {
            final success = response['success'];
            print(success);
            if (success[0] && success[1]) {
              if (response["quadrantList"] != null &&
                  response['calendarData'] != null) {
                final quadrantListInfo = response["quadrantList"];
                print(
                    'get all stats ${quadrantListInfo} && ${response['calendarData']}');
                setState(() {
                  chartData = quadrantListInfo['pieChart'];
                  calendarData = response['calendarData'];
                  topThreeVirtues = quadrantListInfo['topThreeVirtues'];
                  bottomThreeVirtues = quadrantListInfo['bottomThreeVirtues'];
                });
              }
            } else if (success[0] && success[1] == false) {
            } else if (success[0] == false && success[1]) {}
          }
          print('response in redner bto $response');
          Text('loading');
        },
        error: (error, st) {
          Text('ero $error');
        },
        loading: () => const Center(child: CircularProgressIndicator()));
    return Scaffold(
        backgroundColor: Color(0xFFEFE5CC),
        appBar: AppBarWidget('regular'),
        body: Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFFDF9),
            border: Border.all(color: Color(0xFFFEFE5CC), width: 9.0),
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(0.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Colours.white,
                  child: Center(
                      child: Expanded(
                          child:
                              calendar.customCalender(context, calendarData))),
                ),
                Column(
                  children: [
                    RenderPieChart(chartData: chartData),
                    Divider(
                      endIndent: 10,
                      indent: 10,
                      color: Colours.swatch("#534D3F"),
                      height: MediaQuery.of(context).size.height / 35,
                    ),
                    RenderQuadrantUsedList(
                      topThreeVirtues: topThreeVirtues,
                      bottomThreeVirtues: bottomThreeVirtues,
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }
}

class RenderPieChart extends ConsumerWidget {
  const RenderPieChart({super.key, required this.chartData});
  final List<ChartData> chartData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SfCircularChart(series: <CircularSeries>[
      // Render pie chart
      PieSeries<ChartData, String>(
          dataSource: chartData,
          pointColorMapper: (ChartData data, _) => data.color,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y)
    ]);
  }
}

class RenderQuadrantUsedList extends StatelessWidget {
  const RenderQuadrantUsedList(
      {super.key, this.topThreeVirtues, this.bottomThreeVirtues});
  final Map<String, int>? topThreeVirtues;
  final Map<String, int>? bottomThreeVirtues;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Container(
          padding: EdgeInsets.all(8),
          child: Column(children: [
            Center(
              child: Text(
                "Top 3 Virtues",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.italic,
                  color: Colours.swatch(clrBlack),
                ),
              ),
            ),
            TopBottomVirtuesWidget(
              virtueList: topThreeVirtues,
            )
          ]),
        )),
        Expanded(
            child: Container(
          padding: EdgeInsets.all(8),
          child: Column(children: [
            Center(
              child: Text(
                "Bottom 3 Virtues",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.italic,
                  color: Colours.swatch(clrBlack),
                ),
              ),
            ),
            TopBottomVirtuesWidget(
              virtueList: bottomThreeVirtues,
            )
          ]),
        )),
      ],
    );
  }
}

class TopBottomVirtuesWidget extends StatelessWidget {
  const TopBottomVirtuesWidget({
    super.key,
    this.virtueList,
  });

  final Map<String, int>? virtueList;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final entry = virtueList!.entries.elementAt(index);
        final key = entry.key;
        final value = entry.value;
        print('key: $key and val: $value');
        return Container(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    color: Colours.swatch(clrCompassion),
                  ),
                ),
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(key,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.italic,
                              color: Colours.swatch(clrBlack),
                            ))),
                    Text(value.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.italic,
                          color: Colours.swatch(clrBlack),
                        ))
                  ],
                )),
              ],
            ));
      },
      itemCount: virtueList!.length,
    );
  }
}

// class RenderBottom extends ConsumerWidget {
//   const RenderBottom({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return ref.watch(statsControllerProvider).when(
//         data: (response) {
//           if (response != null && response['success'] != null) {
//             final success = response['success'];
//             print(success);
//             if (success[0] && success[1]) {
//               if (response["quadrantList"] != null &&
//                   response['calendarData'] != null) {
//                 final quadrantListInfo = response["quadrantList"];
//                 print(
//                     'get all stats ${quadrantListInfo} && ${response['calendarData']}');

//                 return Column(children: [
//                   RenderPieChart(chartData: quadrantListInfo['pieChart']),
//                   Divider(
//                     endIndent: 10,
//                     indent: 10,
//                     color: Colours.swatch("#534D3F"),
//                     height: MediaQuery.of(context).size.height / 35,
//                   ),
//                   RenderQuadrantUsedList(
//                     topThreeVirtues: quadrantListInfo['topThreeVirtues'],
//                     bottomThreeVirtues: quadrantListInfo['bottomThreeVirtues'],
//                   )
//                 ]);
//               }
//             } else if (success[0] && success[1] == false) {
//             } else if (success[0] == false && success[1]) {}
//           }
//           print('response in redner bto $response');
//           return Text('loading');
//         },
//         error: (error, st) {
//           return Text('ero $error');
//         },
//         loading: () => const Center(child: CircularProgressIndicator()));
//   }
// }

// class RenderCalendar extends ConsumerWidget {
//   const RenderCalendar({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return ref.watch(statsControllerProvider).when(
//         data: (response) {
//           if (response != null) {
//             final success = response['success'];
//             if (success[0] && success[1]) {
//             } else if (success[0] && success[1] == false) {
//             } else if (success[0] == false && success[1]) {}
//           }
//           print('response in redner bto $response');

//           return Text("data");
//         },
//         error: (error, st) {
//           return Text('ero $error');
//         },
//         loading: () => Center(child: CircularProgressIndicator()));
//   }
// }
