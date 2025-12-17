import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:kheabia/models/pointer.dart';
import 'package:kheabia/providers/network_provider.dart';
import 'package:kheabia/utils/const.dart';
import 'package:provider/provider.dart';

class ProcessScannedData extends StatefulWidget {
  final String data;

  // ! Data must be like this  ( - subjectID - doctorID - date - )
  // ? starting and ending with parentheses
  // ? has space between each word
  // ? has 4 dashes ( - )
  // ? has 2 parentheses
  // ? date in format dd/mm/yyyy or mm/dd/yyyy

  const ProcessScannedData({Key key, this.data}) : super(key: key);

  @override
  _ProcessScannedDataState createState() => _ProcessScannedDataState();
}

class _ProcessScannedDataState extends State<ProcessScannedData> {
  bool dataIsValid;
  bool isAlreadyExist = false;
  bool started = false;

  String msg = '';
  String date = '';
  String subjectCode = '';
  String doctorID = '';

  NetworkProvider networkProvider;

  @override
  void initState() {
    super.initState();
  }

  void makeDataProcessing() {
    started = true;
    setState(() {});
    int numberOfHash = 0;
    int numberOfParenthess = 0;

    for (int i = 0; i < widget.data.length; i++) {
      if (widget.data[i] == '-') {
        numberOfHash += 1;
      }
    }

    for (int i = 0; i < widget.data.length; i++) {
      if (widget.data[i] == ')' || widget.data[i] == '(') {
        numberOfParenthess += 1;
      }
    }

    // if data has 4 dashes and 2 parentheses
    if (numberOfHash == 4 &&
        numberOfParenthess == 2 &&
        widget.data.length >= 12) {
      // init date regular expression
      RegExp dateReg = RegExp(
        r'^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[13-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$',
      );

      // split data according to the space
      List<String> words = widget.data.split(' ');

      // date should be in the index 6 so got it
      date = words[6];

      // if date has match with the regular expression
      if (dateReg.hasMatch(date)) {
        // store the subject code in a var and doctor id
        subjectCode = words[2];
        doctorID = words[4];

        // then start to register student in the database
        registerStudent();

        // if date not has match so data are wrong
      } else {
        dataIsValid = false;
      }

      // if has not 3 dashes and 2 parentheses so data are wrong
    } else {
      dataIsValid = false;
    }
  }

  // register student in the current lecture
  void registerStudent() async {
    // get current date in a format like 27/5/1998
    var now = new DateTime.now();
    var formatter = new DateFormat('dd/MM/yyyy');
    String formatted = formatter.format(now);

    // get a copy from stored data for the current std in that course
    DocumentSnapshot stdSnapshot = await Firestore.instance
        .collection('Subjects')
        .document(subjectCode)
        .collection('Students')
        .document('${Pointer.currentStudent.id}')
        .get();

    if (stdSnapshot == null || stdSnapshot.documentID.isEmpty) {
      return;
    }

    String lastRegisteredDate = stdSnapshot.data['Last attendance'];

    if (lastRegisteredDate != formatted) {
      DocumentSnapshot snapshot = await Firestore.instance
          .collection('Subjects')
          .document(subjectCode)
          .get();

      int currentCount = int.parse(snapshot.data['currentCount']);

      dataIsValid = true;
      int currentNumberOfTimes = int.parse(stdSnapshot.data['numberOfTimes']);
      await Firestore.instance
          .collection('Subjects')
          .document(subjectCode)
          .collection('Students')
          .document('${Pointer.currentStudent.id}')
          .updateData(
        {
          'numberOfTimes': '${++currentNumberOfTimes}',
          'attendenc': FieldValue.arrayUnion(['$currentCount']),
          'Last attendance': formatted,
        },
      );
      msg = '';
      isAlreadyExist = false;
    } else {
      msg = 'لقد تم تسجيل حضورك بالفعل';
      isAlreadyExist = true;
      dataIsValid = false;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    networkProvider = Provider.of<NetworkProvider>(context);
    if (networkProvider.hasNetworkConnection != null &&
        networkProvider.hasNetworkConnection &&
        !started) {
      makeDataProcessing();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Const.mainColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'تحليل البيانات',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
      body: networkProvider.hasNetworkConnection == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : networkProvider.hasNetworkConnection
              ? dataIsValid == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'جاري فحص البيانات',
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(8),
                          ),
                          CircularProgressIndicator(),
                        ],
                      ),
                    )
                  : dataIsValid
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                'assets/images/true_data.jpg',
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(28),
                              ),
                              Text(
                                "تم تسجيل حضورك",
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 22,
                                ),
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(28),
                              ),
                              OutlineButton(
                                borderSide: BorderSide(color: Const.mainColor),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'خروج',
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          color: Colors.white,
                          height: ScreenUtil.screenHeight,
                          width: ScreenUtil.screenWidth,
                          child: Center(
                            child: isAlreadyExist
                                ? Column(
                                    children: <Widget>[
                                      Expanded(
                                        child: Image.asset(
                                          'assets/images/already_exist.jpg',
                                        ),
                                      ),
                                      Text(
                                        msg,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 22,
                                        ),
                                      ),
                                      SizedBox(
                                        height: ScreenUtil().setHeight(190),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'نتائج الفحص هي',
                                        style: TextStyle(fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(
                                          height: ScreenUtil().setHeight(8)),
                                      Text(
                                        '${widget.data}',
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                          ),
                        )
              : Container(
                  color: Color(0xffF2F2F2),
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        'assets/images/no_internet_connection.jpg',
                      ),
                      Text(
                        'لا يوجد اتصال بالانترنت',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
