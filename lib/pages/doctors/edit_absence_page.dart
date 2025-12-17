import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kheabia/animations/fade_animation.dart';
import 'package:kheabia/models/doctor_absence_model.dart';
import 'package:kheabia/models/pointer.dart';
import 'package:kheabia/models/subject.dart';
import 'package:kheabia/providers/network_provider.dart';
import 'package:kheabia/utils/app_utils.dart';
import 'package:kheabia/utils/const.dart';
import 'package:kheabia/widgets/my_drop_down_form_field.dart';
import 'package:progress_indicator_button/progress_button.dart';
import 'package:provider/provider.dart';

class EditAbsencePage extends StatefulWidget {
  @override
  _EditAbsencePageState createState() => _EditAbsencePageState();
}

class _EditAbsencePageState extends State<EditAbsencePage> {
  List<Map<String, String>> subjects = [];
  List<DoctorAbsenceModel> students = List();
  List<Subject> subjectsData = [];
  final Firestore _firestore = Firestore.instance;

  String subject = '';
  String student = '';
  String course = '';
  List<Map<String, String>> _students = [];
  List<Map<String, String>> _courses = [];
  DoctorAbsenceModel temp;

  // 0 >> Absence    ||    1 >> Exist
  int selectedRadio;

  @override
  void initState() {
    super.initState();
    selectedRadio = 0;
  }

  setSelectedRadio(int val) {
    setState(
      () {
        selectedRadio = val;
      },
    );
  }

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
        networkProvider.hasNetworkConnection) {
      if (subjects.isEmpty) {
        getDoctorSubjects();
      }
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
          'تعديل الغياب',
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
                        tag: 'assets/images/4.jpg',
                        child: Image.asset(
                          'assets/images/4.jpg',
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
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(16.0),
                          vertical: ScreenUtil().setHeight(12),
                        ),
                        child: MyFadeAnimation(
                          delayinseconds: 1.5,
                          child: MyDropDownFormField(
                            titleStyle: TextStyle(
                              color: Const.mainColor,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Const.mainColor,
                              ),
                            ),
                            titleText: 'الطلاب',
                            hintText: 'اختر الطالب',
                            itemStyle: TextStyle(
                              color: Colors.black,
                            ),
                            value: student,
                            onSaved: (value) {
                              handleStudentSelection(value);
                            },
                            onChanged: (value) {
                              handleStudentSelection(value);
                            },
                            dataSource: _students,
                            textField: 'display',
                            valueField: 'value',
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(16.0),
                          vertical: ScreenUtil().setHeight(12),
                        ),
                        child: MyFadeAnimation(
                          delayinseconds: 2,
                          child: MyDropDownFormField(
                            titleStyle: TextStyle(
                              color: Const.mainColor,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Const.mainColor,
                              ),
                            ),
                            titleText: 'المحاضرات',
                            hintText: 'اختر المحاضرة',
                            itemStyle: TextStyle(
                              color: Colors.black,
                            ),
                            value: course,
                            onSaved: (value) {
                              course = value;
                              setState(() {});
                            },
                            onChanged: (value) {
                              course = value;
                              print(course);
                              setState(() {});
                            },
                            dataSource: _courses,
                            textField: 'display',
                            valueField: 'value',
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(15),
                      ),
                      MyFadeAnimation(
                        delayinseconds: 2.5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                setSelectedRadio(0);
                              },
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    'غائب',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                  Radio(
                                    value: 0,
                                    groupValue: selectedRadio,
                                    onChanged: (int val) {
                                      setSelectedRadio(val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setSelectedRadio(1);
                              },
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    'حاضر',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                  Radio(
                                    value: 1,
                                    groupValue: selectedRadio,
                                    onChanged: (int val) {
                                      setSelectedRadio(val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      MyFadeAnimation(
                        delayinseconds: 3,
                        child: Container(
                          height: ScreenUtil().setHeight(48),
                          margin: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(38),
                            vertical: ScreenUtil().setHeight(18),
                          ),
                          child: ProgressButton(
                            borderRadius: BorderRadius.circular(30),
                            color: Const.mainColor,
                            child: Text(
                              'تعديل',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                            onPressed: (AnimationController controller) {
                              edit(controller, context);
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(30),
                      ),
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

  void handleStudentSelection(value) {
    course = '';
    _courses.clear();
    student = value;

    temp = students.firstWhere((currentStd) => currentStd.std_id == value);
    print(temp.std_name);

    for (int i = 0; i < int.parse(students[0].currentCount); i++) {
      _courses.add(
        {
          'display': 'المحاضرة  ${i + 1}',
          'value': '${i + 1}',
        },
      );
    }
    setState(() {});
  }

  void handleSubjectSelection(value) async {
    subject = value;
    course = '';
    _courses.clear();
    students.clear();
    _students.clear();
    student = '';
    setState(() {});

    // fetch all students inside current subject
    QuerySnapshot studentQuerySnapshot = await _firestore
        .collection('Subjects')
        .document('$subject')
        .collection('Students')
        .getDocuments();

    for (int i = 0; i < studentQuerySnapshot.documents.length; i++) {
      DoctorAbsenceModel model = DoctorAbsenceModel(
        std_id: studentQuerySnapshot.documents[i].data['id'],
        std_name: studentQuerySnapshot.documents[i].data['std_name'],
        lastAttendance:
            studentQuerySnapshot.documents[i].data['Last attendance'],
        numberOfTimes: studentQuerySnapshot.documents[i].data['numberOfTimes'],
        attendenc: studentQuerySnapshot.documents[i].data['attendenc'],
        currentCount: subjectsData[0].currentCount,
      );

      students.add(model);
    }

    for (int i = 0; i < students.length; i++) {
      _students.add(
        {
          'display': '${students[i].std_name}',
          'value': '${students[i].std_id}',
        },
      );
    }

    setState(() {});
  }

  void edit(AnimationController controller, BuildContext context) async {
    if (subject == null || subject.isEmpty || subject == '') {
      AppUtils.showToast(msg: 'حدد المادة');
      return;
    }
    if (student == null || student.isEmpty || student == '') {
      AppUtils.showToast(msg: 'حدد الطالب');
      return;
    }
    if (course == null || course.isEmpty || course == '') {
      AppUtils.showToast(msg: 'حدد المحاضرة');
      return;
    }

    controller.forward();

    var fir = _firestore
        .collection('Subjects')
        .document(subject)
        .collection('Students')
        .document(student);

    int numberOfTimes = int.parse(temp.numberOfTimes);
    if (selectedRadio == 0) {
      if (numberOfTimes != 0 || numberOfTimes > -1) {
        await fir.updateData(
          {
            'attendenc': FieldValue.arrayRemove(['$course']),
            'numberOfTimes': '${--numberOfTimes}',
          },
        );
      }
    } else {
      var selectedStd = students.firstWhere((std) => std.std_id == student);

      print(numberOfTimes);
      print(int.parse(selectedStd.currentCount));

      if (numberOfTimes >= int.parse(selectedStd.currentCount)) {
        AppUtils.showDialog(
          context: context,
          title: 'ملاحظة',
          negativeText: null,
          positiveText: 'تم',
          onPositiveButtonPressed: () {
            Navigator.of(context).pop();
          },
          contentText: 'الطالب حاضر جميع المحاضرات بالفعل',
        );

        controller.reverse();
        return;
      }
      await fir.updateData(
        {
          'attendenc': FieldValue.arrayUnion(['$course']),
          'numberOfTimes': '${++numberOfTimes}',
        },
      );
    }

    AppUtils.showDialog(
      context: context,
      title: 'نجاح',
      negativeText: null,
      positiveText: 'تم',
      onPositiveButtonPressed: () {
        Navigator.of(context).pop();
      },
      contentText: 'تمت العملية بنجاح',
    );

    course = '';
    _courses.clear();
    student = '';
    temp = null;
    setState(() {});

    controller.reverse();
  }
}
