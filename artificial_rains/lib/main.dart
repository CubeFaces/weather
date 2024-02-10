import 'dart:ui';
import 'package:artificial_rains/weather_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:translator/translator.dart';

Future<void> main() async {
  var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'en_US',
    supportedLocales: ['ar', 'en_US'],
  );

  runApp(LocalizedApp(delegate, const MyApp()));
}

String formatDate(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}

List<String> anthropogenicCloudSteps = [
  '.التأكد من أن الهواء قريب من التشبع ببخار الماء',
  '.تبريد الهواء إلى درجة الندى مع مراعاة الماء (أو الجليد) لتكثيف (أو تبخر) جزء من بخار الماء',
  '.التأكد من أن الهواء يحتوي على نوى تكثيف، وهي جزيئات صلبة صغيرة، حيث يبدأ التكثيف/التبخر',
  ':استخدام عمليات تشمل احتراق الوقود الأحفوري، حيث تعزز هذه العمليات الظروف الثلاث الضرورية',
  '  .أ. يُولِّد احتراق الوقود الأحفوري بخار الماء',
  '  .ب. يُولِّد الاحتراق جزيئات صلبة صغيرة يمكن أن تعمل كنوى تكثيف',
  '  .ج. تُطلق عمليات الاحتراق طاقة تعزز الحركات الرأسية الصاعدة',
  '.المشاركة في أنشطة بشرية معينة، مثل محطات الطاقة الحرارية، أو الطائرات التجارية، أو صناعات الكيماويات، التي تعديل الظروف الجوية بما يكفي لإنتاج سحب ذات أصل إنساني',
];

Map<String, String> cityMapping = {
  "مدينة الكويت": "Kuwait City",
  "صباح السالم": "Sabah Al Salem, Kuwait",
  "السالمية": "Salmiya",
  "الأحمدي": "Ahmadi",
  "الجهراء": "Al Jahra",
  "حولي": "Hawally",
  "المرقاب": "Mirqab",
  "جليب الشيوخ": "Jaleeb Al Shoyoukh.",
  "الخيطان": "Khaitan",
  "الزور": "Zour",
  "القرطبة": "Qortuba",
  "أبو حليفة": "Abu Halifa, KW",
};
Map<String, String> cityMappingAR = {
  "Kuwait City": "مدينة الكويت",
  "Sabah Al Salem, Kuwait": "صباح السالم",
  "Salmiya": "السالمية",
  "Ahmadi": "الأحمدي",
  "Al Jahra": "الجهراء",
  "Hawally": "حولي",
  "Mirqab": "المرقاب",
  "Jaleeb Al Shoyoukh.": "جليب الشيوخ",
  "Khaitan": "الخيطان",
  "Zour": "الزور",
  "Qortuba": "القرطبة",
  "Abu Halifa, KW": "أبو حليفة",
};
Map<String, String> appMappingAR = {
  'is Able for Artificial Rains': 'قادرة على الأمطار الاصطناعية',
  'is Not Able for Artificial Rains': 'غير قادرة على الأمطار الاصطناعية',
};
Map<String, String> conditionMappingAR = {
  'High Temperature': 'درجة حرارة عالية',
  'Cloud Coverage Low%': 'نسبة تغطية السحب منخفضة',
  'Low Humidity': 'رطوبة منخفضة',
  'no Rainfall Since': 'لم تكن هناك أمطار منذ فتره طويله',
  'Low Average Rainfall Days': 'أيام هطول مطر قليلة',
  'Low Precipitation': 'هطول مطر منخفض',
};

Map<String, String> needMappingAR = {
  'Needs Artificial Rains': 'تحتاج إلى أمطار صناعية',
  'Does Not Require': 'لا تحتاج',
};

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static String startingDate = formatDate(DateTime(2020));
  static String endingDate = formatDate(DateTime(2024));
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget buildChoosePage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 100,
          ),
          DatePicker(
            onDatesChanged: (DateTime start, DateTime end) {
              MyApp.startingDate = formatDate(start);
              MyApp.endingDate = formatDate(end);
            },
          ),
          for (var menu in dropdownMenus)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  menu,
                  IconButton(
                    onPressed: () {
                      setState(() {
                        dropdownMenus.removeLast();
                      });
                    },
                    icon: const Icon(Icons.clear_rounded),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget buildApplicabilityPage() {
    return applicability.isNotEmpty
        ? ListView.builder(
            itemCount: applicability.length,
            itemBuilder: (context, index) => Card(
              child: ListTile(
                enabled: true,
                tileColor: Colors.lightBlue[50],
                leading: const CircleAvatar(
                  child: Image(
                    image: NetworkImage(
                        "https://cdn-icons-png.flaticon.com/512/197/197459.png"),
                  ),
                ),
                title: Text(applicability[index]),
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        height: 500,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              if (isApplicable)
                                const Text(
                                  '.تغطية السحب في هذه المدينة كافية لإحداث الأمطار الاصطناعية',
                                  style: TextStyle(fontSize: 18),
                                )
                              else
                                Column(
                                  children: [
                                    // Display steps for making Anthropogenic clouds
                                    const Text(
                                      ':خطوات صنع السحب',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    // Use ListView.builder to display steps in a numbered list
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: anthropogenicCloudSteps.length,
                                      itemBuilder:
                                          (BuildContext context, int i) {
                                        return ListTile(
                                          leading: Text('${i + 1}.'),
                                          title:
                                              Text(anthropogenicCloudSteps[i]),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                child: const Text('إغلاق'),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
  }

  final translator = GoogleTranslator();
  Widget buildRankingPage() {
    return weatherResultsUpdated.isNotEmpty
        ? ListView.builder(
            itemCount: weatherResultsUpdated.length,
            itemBuilder: (context, index) => Card(
              child: ListTile(
                enabled: true,
                tileColor: Colors.lightBlue[50],
                leading: CircleAvatar(
                  backgroundColor: Colors.lightBlue,
                  child: Text(
                    "${index + 1}#",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: () {
                  var r = separateCity(weatherResultsUpdated[index]);
                  if (cityMappingAR[r[0]].toString() != 'null') {
                    return Text(
                      "${cityMappingAR[r[0]].toString()} ${needMappingAR[r[1]].toString()}",
                    );
                  } else {
                    return const Text(".اختر مدينة وحاول مرة أخرى");
                  }
                }(),
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      for (List<String> conditionsList in metConditionsList) {
                        for (int i = 0; i < conditionsList.length; i++) {
                          if (conditionsList[i] == "Cloud Coverage Low%") {
                            isApplicable = false;
                          }
                        }
                      }
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        height: 500,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Text(
                                ':تعاني هذه المدينة من',
                                style: TextStyle(fontSize: 20.0),
                              ),
                              const SizedBox(height: 10),
                              // Iterate over each sublist in metConditionsList
                              for (List<String> conditionsList
                                  in metConditionsList)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Iterate over items in the current sublist
                                    for (int i = 0;
                                        i < conditionsList.length;
                                        i++)
                                      ListTile(
                                        leading: Text('${i + 1}.'),
                                        title: Text(conditionMappingAR[
                                                conditionsList[i]]
                                            .toString()),
                                      ),
                                  ],
                                ),

                              const SizedBox(height: 10),
                              ElevatedButton(
                                child: const Text('إغلاق'),
                                onPressed: () {
                                  // Do something with isApplicable

                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          )
        : (singleResultsUpdated.isNotEmpty && singleCityPressed
            ? Builder(builder: (context) {
                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          height: 600,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: cityConditionsList[0].length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Column(
                                      children: [
                                        FutureBuilder<String>(
                                          future: translateTitle(
                                              cityConditionsList[0][index]),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<String> snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const CircularProgressIndicator(); // Or a loading indicator
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                  'Error: ${snapshot.error}');
                                            } else {
                                              return Text(
                                                "${snapshot.data}: ${conditionsStatements[index]}",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 15),
                                              );
                                            }
                                          },
                                        ),
                                        const Divider(
                                          thickness: 1,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                ElevatedButton(
                                  child: const Text('إغلاق'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Center(
                    child: SizedBox(
                      width: 400,
                      height: 440,
                      child: Card(
                        color: Colors.lightBlue[50],
                        elevation: 5,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            const Image(
                              height: 200,
                              width: 200,
                              image: NetworkImage(
                                  "https://uxwing.com/wp-content/themes/uxwing/download/flags-landmarks/kuwait-flag-round-circle-icon.png"),
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            FutureBuilder<String>(
                              future: translateTitle(singleResultsUpdated[0]),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator(); // Or a loading indicator
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return Text(
                                    singleResultsUpdated[0],
                                    style: const TextStyle(fontSize: 24),
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                  );
                                }
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            FutureBuilder<String>(
                              future: translateTitle(cityApplicability[0]),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator(); // Or a loading indicator
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return Text(
                                    "لاحظ أن ${cityApplicability[0]}",
                                    style: const TextStyle(fontSize: 14),
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                  );
                                }
                              },
                            ),
                            const SizedBox(
                              height: 35,
                            ),
                            const Text(
                              "انقر للمزيد من التفاصيل",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                              textAlign: TextAlign.center,
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              })
            : const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              ));
  }

  Widget buildSelectPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          height: 100,
        ),
        DatePicker(
          onDatesChanged: (DateTime start, DateTime end) {
            MyApp.startingDate = formatDate(start);
            MyApp.endingDate = formatDate(end);
          },
        ),
        Center(
          heightFactor: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              selectCity,
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            setState(() {
              int prevPageIndex = (currentPageIndex - 1) % 5;
              pageController.animateToPage(
                prevPageIndex,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.bounceOut,
              );
              weatherResultsUpdated = [];
              singleResultsUpdated = [];
              singleCityPressed = true;
            });
            List<String> result = [
              await weatherUtility.needsArtificialRain(
                  await translateCity(selectCity.currentCity),
                  MyApp.startingDate,
                  MyApp.endingDate)
            ];
            List<String> r = [];
            setState(() {
              singleResultsUpdated = updateAndSortWeatherResults(result);

              cityConditionsList =
                  extractAndRemoveWeatherConditions(singleResultsUpdated);

              cityApplicability =
                  extractAndRemoveApplicability(singleResultsUpdated);
              r = separateCity(singleResultsUpdated[0]);

              singleResultsUpdated[0] =
                  "${cityMappingAR[r[0]]} ${needMappingAR[r[1]]}";
            });

            conditionsStatements = [];
            for (var condition in cityConditionsList[0]) {
              switch (condition) {
                case "High Temperature":
                  conditionsStatements.add(
                      "يُنصَح بأن يوفِّرَ الفلاحون ظلًا كافيًا للمحاصيل، ويزيدوا من تكرار الري، ويختاروا أصناف المحاصيل التي تتحمل الحرارة.");
                  break;
                case "Cloud Coverage Low%":
                  conditionsStatements.add(
                      "عدم وجود السحب يجعل هذه المدينة غير مناسبة للأمطار الاصطناعية. يُنصَح بمراقبة رطوبة التربة عن كثب من قبل الفلاحين.");
                  isApplicable = false;
                  break;
                case "Low Humidity":
                  conditionsStatements.add(
                      "يُنصَح بأن يزيد الفلاحون من الري ويطبقون إجراءات الحفاظ على المياه للحفاظ على رطوبة التربة.");
                  break;
                case "No Rainfall Since":
                  conditionsStatements.add(
                      "يُنصَح بأن يراقب الفلاحون احتياجات الماء للمحاصيل عن كثب، ويطبقون الري الإضافي، ويأخذون في اعتبارهم أصناف المحاصيل التي تتحمل الجفاف.");
                  break;
                case "Low Average Rainfall Days":
                  conditionsStatements.add(
                      "يُنصَح بأن يخطط الفلاحون لاستخدام الماء بكفاءة وتطبيق تقنيات جمع مياه الأمطار.");
                  break;
                case "Low Precipitation":
                  conditionsStatements.add(
                      "يُنصَح بأن يطبق الفلاحون تقنيات توفير المياه، مثل الري بالتنقيط، ويتبنون أصناف المحاصيل المقاومة للجفاف.");
                  break;
                default:
                  conditionsStatements.add(
                      "شرط غير معترف به. يرجى التشاور مع خبراء الزراعة للحصول على نصائح مخصصة.");
              }
            }
          },
          style: const ButtonStyle(
            elevation: MaterialStatePropertyAll(2),
            minimumSize: MaterialStatePropertyAll(Size(80, 50)),
            shape: MaterialStatePropertyAll(
              ContinuousRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(25),
                ),
              ),
            ),
            backgroundColor: MaterialStatePropertyAll(
              Color.fromARGB(255, 59, 157, 255),
            ),
            foregroundColor: MaterialStatePropertyAll(Colors.white),
          ),
          child: const Text(
            "تقديم",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Future<List<String>> translateConditions(List<String> conditions) async {
    List<String> translatedConditions = [];
    for (String condition in conditions) {
      Translation translation =
          await translator.translate(condition, from: 'en', to: 'ar');
      translatedConditions.add(translation.text);
    }
    return translatedConditions;
  }

  Future<String> translateTitle(String title) async {
    Translation translation =
        await translator.translate(title, from: 'en', to: 'ar');
    return translation.text;
  }

  Future<String> translateCity(String title) async {
    Translation translation =
        await translator.translate(title, from: 'ar', to: 'en');
    return translation.text;
  }

  Widget buildConditionsPage() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Center(
        child: SizedBox(
          width: 400,
          height: 700,
          child: Card(
            color: const Color.fromARGB(164, 48, 116, 148),
            child: Builder(
              builder: (BuildContext context) {
                return SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "تحقق من تطابق الظروف",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          TextFormField(
                            cursorColor: Colors.lightBlue,
                            controller: tempController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelStyle: const TextStyle(
                                color: Color.fromARGB(255, 0, 73, 116),
                              ),
                              fillColor:
                                  const Color.fromARGB(122, 110, 200, 255),
                              filled: true,
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.lightBlue),
                              ),
                              focusColor: Colors.lightBlue,
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.lightBlue, width: 2),
                              ),
                              hoverColor: Colors.lightBlue,
                              labelText: 'درجة الحرارة',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                    width: 10, color: Colors.lightBlue),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال قيمة';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            cursorColor: Colors.lightBlue,
                            controller: cloudCoverageController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelStyle: const TextStyle(
                                  color: Color.fromARGB(255, 0, 73, 116)),
                              fillColor:
                                  const Color.fromARGB(122, 110, 200, 255),
                              filled: true,
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.lightBlue),
                              ),
                              focusColor: Colors.lightBlue,
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.lightBlue, width: 2),
                              ),
                              hoverColor: Colors.lightBlue,
                              labelText: '%تغطية السحب',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                    width: 10, color: Colors.lightBlue),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال قيمة';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            cursorColor: Colors.lightBlue,
                            controller: humidityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelStyle: const TextStyle(
                                  color: Color.fromARGB(255, 0, 73, 116)),
                              fillColor:
                                  const Color.fromARGB(122, 110, 200, 255),
                              filled: true,
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.lightBlue),
                              ),
                              focusColor: Colors.lightBlue,
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.lightBlue, width: 2),
                              ),
                              hoverColor: Colors.lightBlue,
                              labelText: 'الرطوبة',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                    width: 10, color: Colors.lightBlue),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال قيمة';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            cursorColor: Colors.lightBlue,
                            controller: lastRainedController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelStyle: const TextStyle(
                                  color: Color.fromARGB(255, 0, 73, 116)),
                              fillColor:
                                  const Color.fromARGB(122, 110, 200, 255),
                              filled: true,
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.lightBlue),
                              ),
                              focusColor: Colors.lightBlue,
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.lightBlue, width: 2),
                              ),
                              hoverColor: Colors.lightBlue,
                              labelText: 'الأيام منذ آخر هطول للأمطار',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                    width: 10, color: Colors.lightBlue),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال قيمة';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            cursorColor: Colors.lightBlue,
                            controller: precipitationController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelStyle: const TextStyle(
                                  color: Color.fromARGB(255, 0, 73, 116)),
                              fillColor:
                                  const Color.fromARGB(122, 110, 200, 255),
                              filled: true,
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.lightBlue),
                              ),
                              focusColor: Colors.lightBlue,
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.lightBlue, width: 2),
                              ),
                              hoverColor: Colors.lightBlue,
                              labelText: 'كميه الهطول',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                    width: 10, color: Colors.lightBlue),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال قيمة';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            cursorColor: Colors.lightBlue,
                            controller: avgRainfallDaysController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelStyle: const TextStyle(
                                  color: Color.fromARGB(255, 0, 73, 116)),
                              fillColor:
                                  const Color.fromARGB(122, 110, 200, 255),
                              filled: true,
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.lightBlue),
                              ),
                              focusColor: Colors.lightBlue,
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.lightBlue, width: 2),
                              ),
                              hoverColor: Colors.lightBlue,
                              labelText: '"متوسط أيام هطول الأمطار في السنة',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                    width: 10, color: Colors.lightBlue),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال قيمة';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (_formKey.currentState!.validate()) {
                                  int counter = 0;

                                  String applicability =
                                      "قابلة للأمطار الاصطناعية. يمكن إنشاء الأمطار الاصطناعية من خلال تحفيز السحب.";
                                  // Access the entered values using text controllers
                                  double temperature =
                                      double.parse(tempController.text);
                                  double cloudCoverage = double.parse(
                                      cloudCoverageController.text);
                                  double humidity =
                                      double.parse(humidityController.text);
                                  double lastRained =
                                      double.parse(lastRainedController.text);
                                  double precipitation = double.parse(
                                      precipitationController.text);
                                  double avgRainfallDays = double.parse(
                                      avgRainfallDaysController.text);
                                  if (temperature >
                                      WeatherUtility
                                          .HIGH_TEMPERATURE_THRESHOLD) {
                                    counter++;
                                  }

                                  if (cloudCoverage <=
                                      WeatherUtility.LOW_CLOUD_THRESHOLD) {
                                    counter++;
                                    applicability =
                                        "لا يوجد ما يكفي من السحب لتحفيز السحب، يُقترح استخدام السحب الاصطناعية\n\nثلاثة شروط تحتاج إلى توفرها لتشكيل سحابة بشرية:\n\n1. يجب أن يكون الهواء قريبًا من التشبع ببخار الماء.\n\n2. يجب أن يتم تبريد الهواء إلى درجة الندى بالنسبة للماء (أو الجليد) لتكثيف (أو تحول) جزء من بخار الماء.\n\n3. يجب أن يحتوي الهواء على نوى تكثيف، وهي جسيمات صلبة صغيرة، حيث يبدأ التكثيف/التحول..";
                                  }

                                  if (humidity <=
                                      WeatherUtility.LOW_HUMIDITY_THRESHOLD) {
                                    counter++;
                                  }

                                  if (lastRained >=
                                      WeatherUtility
                                          .DAYS_SINCE_RAINFALL_THRESHOLD) {
                                    counter++;
                                  }

                                  if (avgRainfallDays <=
                                      WeatherUtility
                                          .LOW_RAINFALL_DAYSAVG_THRESHOLD) {
                                    counter++;
                                  }

                                  if (precipitation <=
                                      WeatherUtility
                                          .LOW_PRECIPITATION_THRESHOLD) {
                                    counter++;
                                  }

                                  if (counter >= 3) {
                                    showModalBottomSheet<void>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white70,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          height: 500,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                  'تحتاج إلى أمطار اصطناعية, $applicability',
                                                  style: const TextStyle(
                                                      fontSize: 20.0),
                                                ),
                                                ElevatedButton(
                                                  child: const Text('إغلاق'),
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  } else {
                                    showModalBottomSheet<void>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white70,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          height: 500,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                const Text(
                                                  'الشروط المقدمة لا تتطلب الأمطار الاصطناعية.',
                                                  style:
                                                      TextStyle(fontSize: 20.0),
                                                ),
                                                ElevatedButton(
                                                  child: const Text('إغلاق'),
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                }
                              });
                            },
                            style: const ButtonStyle(
                              shape: MaterialStatePropertyAll(
                                BeveledRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                              ),
                              backgroundColor: MaterialStatePropertyAll(
                                Color.fromARGB(255, 0, 102, 255),
                              ),
                            ),
                            child: const Text(
                              'تحقق',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  int currentPageIndex = 0;
  bool singleCityPressed = false;
  bool isApplicable = true;
  PageController pageController = PageController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController tempController = TextEditingController();
  TextEditingController cloudCoverageController = TextEditingController();
  TextEditingController humidityController = TextEditingController();
  TextEditingController lastRainedController = TextEditingController();
  TextEditingController precipitationController = TextEditingController();
  TextEditingController avgRainfallDaysController = TextEditingController();
  DropdownCityMenu selectCity = DropdownCityMenu(
    key: UniqueKey(),
  );

  List<String> singleResultsUpdated = [];
  List<String> conditionsStatements = [];
  List<String> cityApplicability = [];
  List<List<String>> cityConditionsList = [];
  List<DropdownCityMenu> dropdownMenus = [];
  List<String> selectedCities = [];
  WeatherUtility weatherUtility = WeatherUtility();
  List<String> weatherResults = ["لم يتم اختيار أي مدن"];
  List<String> weatherResultsUpdated = [".اختر مدينة وحاول مرة أخرى"];
  List<List<String>> metConditionsList = [
    ["لم يتم اختيار أي مدينة"]
  ];
  List<String> applicability = ["!اختر المدن أولاً"];
  List<String> updateAndSortWeatherResults(List<String> weatherResults) {
    Map<String, int> resultWithNumbers = {};
    for (String result in weatherResults) {
      String numberString = result.split(' ').last;
      int number = int.tryParse(numberString) ?? 0;
      resultWithNumbers[result] = number;
    }

    List<MapEntry<String, int>> sortedResults = resultWithNumbers.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    weatherResults.clear();
    weatherResults.addAll(sortedResults
        .map((entry) => entry.key.replaceAll(RegExp(r'\d+$'), '').trim()));

    return weatherResults;
  }

  List<String> extractAndRemoveApplicability(List<String> weatherResults) {
    List<String> extractedApplicabilities = [];

    for (int i = 0; i < weatherResults.length; i++) {
      String result = weatherResults[i];

      // Extract applicability
      RegExp exp = RegExp(
          r'is Able for Artificial Rains|is Not Able for Artificial Rains');
      Iterable<RegExpMatch> matches = exp.allMatches(result);
      String applicability =
          matches.isNotEmpty ? matches.first.group(0) ?? "" : "";

      // Remove applicability from the original string
      String resultWithoutApplicability = result.replaceAll(exp, '').trim();
      weatherResults[i] = resultWithoutApplicability;
      weatherResults[i] =
          weatherResults[i].replaceAll(RegExp(r'\s*-\s*.+'), '').trim();

      // Extract city from the result (allowing for two-word city names)
      RegExp cityExp = RegExp(r'(.+?(?=\s*Needs Artificial Rains))');

      Iterable<RegExpMatch> cityMatches = cityExp.allMatches(result);
      String city =
          cityMatches.isNotEmpty ? cityMatches.first.group(1) ?? "" : "";
      city = cityMappingAR[city].toString();
      applicability = appMappingAR[applicability].toString();
      // Add city to the applicability
      applicability = "$city $applicability";

      extractedApplicabilities.add(applicability);
    }

    return extractedApplicabilities;
  }

  List<String> separateCity(String sentence) {
    // Define a regular expression to match the city
    RegExp cityRegExp =
        RegExp(r'^(.+) (?:Needs Artificial Rains|Does Not Require)$');

    // Use RegExp match to extract city and the rest of the sentence
    RegExpMatch? match = cityRegExp.firstMatch(sentence);

    if (match != null) {
      // Extract city and sentence
      String city = match.group(1)?.trim() ?? "";
      String restOfSentence = sentence.endsWith("Does Not Require")
          ? "Does Not Require Artificial Rains"
          : "Needs Artificial Rains";

      // Return the values as a list
      return [city, restOfSentence];
    } else {
      // If the specified sentence is not found, set the default values
      String city = "";
      String restOfSentence = "?";

      // Return the values as a list
      return [city, restOfSentence];
    }
  }

  List<List<String>> extractAndRemoveWeatherConditions(
      List<String> weatherResults) {
    List<List<String>> extractedLists = [];

    for (String result in weatherResults) {
      RegExp exp = RegExp(r'\[(.*?)\]');
      Iterable<RegExpMatch> matches = exp.allMatches(result);

      List<String> conditionsList = [];

      for (RegExpMatch match in matches) {
        conditionsList =
            match.group(1)?.split(',').map((e) => e.trim()).toList() ?? [];
      }
      String resultWithoutConditions =
          result.replaceAll(RegExp(r'\[(.*?)\]'), '').trim();
      weatherResults[weatherResults.indexOf(result)] = resultWithoutConditions;

      extractedLists.add(conditionsList);
    }

    return extractedLists;
  }

  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;
    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          localizationDelegate
        ],
        supportedLocales: localizationDelegate.supportedLocales,
        locale: localizationDelegate.currentLocale,
        home: Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          appBar: AppBar(
            title: const Center(
              child: Text(
                "الأمطار الصناعية",
              ),
            ),
            backgroundColor: const Color.fromARGB(148, 3, 168, 244),
            foregroundColor: Colors.white,
          ),
          bottomNavigationBar: NavigationBar(
            backgroundColor: const Color.fromARGB(200, 255, 255, 255),
            onDestinationSelected: (int index) {
              pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            indicatorColor: Colors.lightBlue,
            selectedIndex: currentPageIndex,
            destinations: const <Widget>[
              NavigationDestination(
                selectedIcon: Icon(Icons.add_circle),
                icon: Icon(Icons.add_circle_outline_outlined),
                label: 'اختر',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.check_circle_outline_outlined),
                icon: Icon(Icons.check_circle),
                label: 'التطبيقية',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.format_list_numbered_rounded),
                icon: Icon(Icons.view_list_rounded),
                label: 'التصنيف',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.location_city_rounded),
                icon: Icon(Icons.location_city_sharp),
                label: 'اختر',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.cloud_circle_outlined),
                icon: Icon(Icons.cloud_circle),
                label: 'الشروط',
              ),
            ],
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  "https://images.unsplash.com/photo-1534088568595-a066f410bcda?q=80&w=1651&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                ),
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12 / 4, sigmaY: 12 / 4),
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentPageIndex = index;
                  });
                },
                itemCount: 5,
                itemBuilder: (context, index) {
                  return [
                    buildChoosePage(),
                    buildApplicabilityPage(),
                    buildRankingPage(),
                    buildSelectPage(),
                    buildConditionsPage(),
                  ][index];
                },
              ),
            ),
          ),
          floatingActionButton: Visibility(
            visible: currentPageIndex == 0 ? true : false,
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    child: FloatingActionButton(
                      backgroundColor: Colors.lightBlueAccent,
                      onPressed: () async {
                        setState(() {
                          int nextPageIndex = (currentPageIndex + 2) % 5;
                          pageController.animateToPage(
                            nextPageIndex,
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeInOut,
                          );

                          singleCityPressed = false;
                        });
                        weatherResults = [];
                        selectedCities = [];
                        weatherResultsUpdated = [];
                        applicability = [];

                        for (var menu in dropdownMenus) {
                          selectedCities.add(menu.currentCity);
                        }

                        for (var city in selectedCities) {
                          String result =
                              await weatherUtility.needsArtificialRain(
                            city,
                            MyApp.startingDate,
                            MyApp.endingDate,
                          );
                          setState(() {
                            weatherResults.add(result);
                          });
                        }
                        setState(() {
                          weatherResultsUpdated =
                              updateAndSortWeatherResults(weatherResults);
                          metConditionsList = extractAndRemoveWeatherConditions(
                              weatherResultsUpdated);

                          applicability = extractAndRemoveApplicability(
                              weatherResultsUpdated);
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'قارن',
                          textAlign: TextAlign.center,
                          softWrap: false,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: FloatingActionButton(
                      backgroundColor: Colors.lightBlueAccent,
                      onPressed: () {
                        setState(
                          () {
                            dropdownMenus.add(
                              DropdownCityMenu(
                                key: UniqueKey(),
                              ),
                            );
                          },
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(left: 15.0),
                        child: Row(
                          children: [
                            Text(
                              "أضف مدينة",
                              textAlign: TextAlign.center,
                            ),
                            Icon(Icons.add)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class DropdownCityMenu extends StatefulWidget {
  DropdownCityMenu({super.key});

  late String currentCity;

  @override
  State<DropdownCityMenu> createState() => DropdownCityMenuState();
}

class DropdownCityMenuState extends State<DropdownCityMenu> {
  List<String> translatedList = [
    "مدينة الكويت",
    "صباح السالم",
    "السالمية",
    "الأحمدي",
    "الجهراء",
    "حولي",
    "المرقاب",
    "جليب الشيوخ",
    "الخيطان",
    "الزور",
    "القرطبة",
    "أبو حليفة"
  ];

  @override
  void initState() {
    widget.currentCity = cityMapping[translatedList.first].toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
      ),
      initialSelection: translatedList.first,
      onSelected: (String? value) {
        setState(() {
          widget.currentCity = cityMapping[value]!.toString();
        });
      },
      dropdownMenuEntries: translatedList.map<DropdownMenuEntry<String>>(
        (String value) {
          return DropdownMenuEntry<String>(
            value: value,
            label: value,
          );
        },
      ).toList(),
    );
  }
}

//a stateful widget to pick a start date and an end date.
class DatePicker extends StatefulWidget {
  final Function(DateTime, DateTime) onDatesChanged;

  const DatePicker({super.key, required this.onDatesChanged});

  @override
  DatePickerState createState() => DatePickerState();
}

class DatePickerState extends State<DatePicker> {
  late TextEditingController controller1;
  late TextEditingController controller2;
  late DateTime selectedDateStart;
  late DateTime selectedDateEnd;

  @override
  void initState() {
    super.initState();

    selectedDateStart = DateTime(2018);
    selectedDateEnd = DateTime(2024);
    controller1 = TextEditingController(text: _formatDate(selectedDateStart));
    controller2 = TextEditingController(text: _formatDate(selectedDateEnd));
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void _updateDates(DateTime newStart, DateTime newEnd) {
    selectedDateStart = newStart;
    selectedDateEnd = newEnd;
    widget.onDatesChanged(selectedDateStart, selectedDateEnd);
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 110,
                child: SizedBox(
                  height: 60,
                  child: TextField(
                    style: const TextStyle(
                      color: Color.fromARGB(180, 0, 0, 0),
                    ),
                    readOnly: true,
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.blue),
                        gapPadding: 0,
                        borderRadius: BorderRadius.all(
                          Radius.circular(200.0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.lightBlue, width: 2.0),
                        borderRadius: BorderRadius.all(
                          Radius.circular(15.0),
                        ),
                      ),
                      label: Center(
                        child: Text(
                          "تاريخ البداية",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: Color.fromARGB(255, 0, 98, 143)),
                        ),
                      ),
                      filled: true,
                      fillColor: Color.fromARGB(80, 0, 157, 255),
                      focusColor: Color.fromARGB(150, 0, 157, 255),
                    ),
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: selectedDateStart,
                        firstDate: DateTime(2010),
                        lastDate: DateTime(2024),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              primaryColor: Colors.blue,
                              hintColor: Colors.blue,
                              colorScheme:
                                  const ColorScheme.dark(primary: Colors.blue),
                              buttonTheme: const ButtonThemeData(
                                textTheme: ButtonTextTheme.primary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      ).then(
                        (value) {
                          if (value != null &&
                              value.isBefore(selectedDateEnd)) {
                            setState(() {
                              _updateDates(value, selectedDateEnd);
                              controller1.text = _formatDate(value);
                            });
                          }
                        },
                      );
                    },
                    controller: controller1,
                  ),
                ),
              ),
              SizedBox(
                width: 110,
                child: SizedBox(
                  height: 60,
                  child: TextField(
                    style: const TextStyle(
                      color: Color.fromARGB(180, 0, 0, 0),
                    ),
                    readOnly: true,
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        gapPadding: 0,
                        borderSide: BorderSide(width: 1, color: Colors.blue),
                        borderRadius: BorderRadius.all(
                          Radius.circular(200.0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.lightBlue, width: 2.0),
                          borderRadius:
                              BorderRadius.all(Radius.circular(15.0))),
                      label: Center(
                        child: Text(
                          "تاريخ الانتهاء",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: Color.fromARGB(255, 0, 98, 143)),
                        ),
                      ),
                      filled: true,
                      fillColor: Color.fromARGB(80, 0, 157, 255),
                      focusColor: Color.fromARGB(150, 0, 157, 255),
                    ),
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: selectedDateEnd,
                        firstDate: selectedDateStart,
                        lastDate: DateTime(2024),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              primaryColor: Colors.blue,
                              hintColor: Colors.blue,
                              colorScheme:
                                  const ColorScheme.dark(primary: Colors.blue),
                              buttonTheme: const ButtonThemeData(
                                textTheme: ButtonTextTheme.primary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      ).then(
                        (value) {
                          if (value != null &&
                              value.isAfter(selectedDateStart)) {
                            setState(() {
                              _updateDates(selectedDateStart, value);
                              controller2.text = _formatDate(value);
                            });
                          }
                        },
                      );
                    },
                    controller: controller2,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
