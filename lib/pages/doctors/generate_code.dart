import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kheabia/models/pointer.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:twitter_qr_scanner/twitter_qr_scanner.dart';

class GenerateCode extends StatefulWidget {
  final String course;

  const GenerateCode({Key key, this.course}) : super(key: key);

  @override
  _GenerateCodeState createState() => _GenerateCodeState();
}

class _GenerateCodeState extends State<GenerateCode> {
  GlobalKey qrKey = GlobalKey();
  QRViewController controller;

  String data;

  @override
  void initState() {
    super.initState();

    // ! Data must be like this  ( - subjectID - doctorID - date - )
    // ? starting and ending with parentheses ()
    // ? has space between each character
    // ? has 4 dash ( - )
    // ? has 2 parentheses
    // ? date in format dd/mm/yyyy or mm/dd/yyyy

    var now = new DateTime.now();
    var formatter = new DateFormat('dd/MM/yyyy');
    String formatted = formatter.format(now);
    print(formatted); // something like 20/04/2020
    data =
        '( - ${widget.course} - ${Pointer.currentDoctor.id} - $formatted - )';
    print('>>>>>>>>>>>>   $data');
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: QrImage(
          data: data,
          version: QrVersions.auto,
          size: MediaQuery.of(context).size.width / 1.5,
          gapless: true,
        ),
      ),
    );
  }
}
