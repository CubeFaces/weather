//a stateful widget to pick a start date and an end date.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
