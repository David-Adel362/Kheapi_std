import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:kheabia/animations/fade_animation.dart';
import 'package:kheabia/models/pointer.dart';
import 'package:kheabia/models/subject.dart';
import 'package:kheabia/pages/doctors/generate_code.dart';
import 'package:kheabia/providers/network_provider.dart';
import 'package:kheabia/utils/app_utils.dart';
import 'package:kheabia/utils/const.dart';
import 'package:kheabia/widgets/my_drop_down_form_field.dart';
import 'package:progress_indicator_button/progress_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectCourseToGenerate extends StatefulWidget {
  @override
  _SelectCourseToGenerateState createState() => _SelectCourseToGenerateState();
}

class _SelectCourseToGenerateState extends State<SelectCourseToGenerate> {
  List<Map<String, String>> subjects = [];
  List<Subject> subjectsData = [];
  final Firestore _firestore = Firestore.instance;
  String subject = '';
  List<String> selectedCourses = <String>[];

  void getDoctorSubjects() async {
    subjects.clear();
    QuerySnapshot querySnapshot = await _firestore
        .collection('Subjects')
        .getDocuments(); // fetch all subjects

    print(querySnapshot.documents.length);
    for (int i = 0; i < querySnapshot.documents.length; i++) {
      // move inside each subject
      DocumentSnapshot currentSubject = querySnapshot.documents[i];

      if (Pointer.currentDoctor.subjects
          .contains(currentSubject.data['code'])) {
        Subject subject = Subject(
          name: currentSubject.data['name'],
          code: currentSubject.data['code'],
          currentCount: currentSubject.data['currentCount'],
          profID: currentSubject.data['profID'],
          profName: currentSubject.data['profName'],
        );

        if (!subjectsData.contains(subject)) {
          subjectsData.add(subject);
          subjects.add(
            {
              'display':
                  '   ${currentSubject.data['code']}                  ${currentSubject.data['name']}',
              'value': currentSubject.data['code'],
            },
          );
        }
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var networkProvider = Provider.of<NetworkProvider>(context);

    if (networkProvider.hasNetworkConnection != null &&
        networkProvider.hasNetworkConnection &&
        subjects.isEmpty) {
      getDoctorSubjects();
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
          'توليد الكود',
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
              ? SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      Hero(
                        tag: 'assets/images/3.jpg',
                        child: Image.asset(
                          'assets/images/3.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: ScreenUtil().setHeight(
                            180,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(16),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(16.0),
                          vertical: ScreenUtil().setHeight(12),
                        ),
                        child: MyFadeAnimation(
                          delayinseconds: 1,
                          child: MyDropDownFormField(
                            titleStyle: TextStyle(
                              color: Const.mainColor,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Const.mainColor,
                              ),
                            ),
                            titleText: 'المواد',
                            hintText: 'اختر المادة',
                            itemStyle: TextStyle(
                              color: Colors.black,
                            ),
                            value: subject,
                            onSaved: (value) {
                              handleSubjectSelection(value);
                            },
                            onChanged: (value) {
                              handleSubjectSelection(value);
                            },
                            dataSource: subjects,
                            textField: 'display',
                            valueField: 'value',
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(40),
                      ),
                      MyFadeAnimation(
                        delayinseconds: 1.5,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          height: ScreenUtil().setHeight(48),
                          margin: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(38),
                            vertical: ScreenUtil().setHeight(18),
                          ),
                          child: ProgressButton(
                            borderRadius: BorderRadius.circular(30),
                            color: Const.mainColor,
                            child: Text(
                              'توليد',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                            onPressed: (AnimationController controller) async {
                              if (subjects == null ||
                                  subjects.length == 0 ||
                                  subjects.isEmpty) {
                                AppUtils.showDialog(
                                  context: context,
                                  title: 'تنبيه',
                                  negativeText: null,
                                  positiveText: 'تم',
                                  onPositiveButtonPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  contentText: 'لا توجد مواد لتوليد الكود لها',
                                );

                                return;
                              }

                              if (subject == null ||
                                  subject == '' ||
                                  subject.isEmpty) {
                                AppUtils.showDialog(
                                  context: context,
                                  title: 'تنبيه',
                                  negativeText: null,
                                  positiveText: 'تم',
                                  onPositiveButtonPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  contentText: 'قم باخيار المادة اولا',
                                );

                                return;
                              }

                              controller.forward();

                              SharedPreferences.getInstance().then(
                                (pref) async {
                                  String lastDate =
                                      pref.getString('lastLecDate') ?? '';

                                  // get current date in a format like 27/5/1998
                                  var now = new DateTime.now();
                                  var formatter = new DateFormat('dd/MM/yyyy');
                                  String formatted = formatter.format(now);

                                  if (lastDate == formatted) {
                                    selectedCourses =
                                        pref.getStringList('selectedCourses') ??
                                            [];

                                    if (selectedCourses.contains(subject)) {
                                      AppUtils.showDialog(
                                        context: context,
                                        title: 'تحذير',
                                        negativeText: '',
                                        onNegativeButtonPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        positiveText: 'حسنا',
                                        onPositiveButtonPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        contentText:
                                            'لقد قمت بانشاء كود بالفعل ومتاح لك انشاء كود مرة واحدة فقط لكل محاضرة في اليوم',
                                      );

                                      controller.reverse();
                                      return;
                                    }
                                  }

                                  selectedCourses.add(subject);
                                  pref.setString('lastLecDate', formatted);
                                  pref.setStringList(
                                    'selectedCourses',
                                    selectedCourses,
                                  );

                                  DocumentSnapshot snapshot = await Firestore
                                      .instance
                                      .collection('Subjects')
                                      .document(subject)
                                      .get();

                                  int currentCount =
                                      int.parse(snapshot.data['currentCount']);

                                  await Firestore.instance
                                      .collection('Subjects')
                                      .document(subject)
                                      .updateData(
                                    {
                                      'currentCount': '${++currentCount}',
                                    },
                                  );

                                  controller.reverse();

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => GenerateCode(
                                        course: subject,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(25),
                      ),
                      MyFadeAnimation(
                        delayinseconds: 2,
                        child: Text(
                          'متاح لك انشاء كود مرة واحدة فقط لكل محاضرة في اليوم',
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
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

  void handleSubjectSelection(value) {
    subject = value;
    setState(() {});
  }
}
