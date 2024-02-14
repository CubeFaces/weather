import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DropdownCityMenu extends StatefulWidget {
  DropdownCityMenu({super.key});

  late String currentCity;

  @override
  State<DropdownCityMenu> createState() => DropdownCityMenuState();
}

class DropdownCityMenuState extends State<DropdownCityMenu> {
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
