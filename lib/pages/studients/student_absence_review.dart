import 'package:kheabia/animations/fade_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kheabia/models/pointer.dart';
import 'package:kheabia/models/subject.dart';
import 'package:kheabia/providers/network_provider.dart';
import 'package:kheabia/utils/app_utils.dart';
import 'package:kheabia/utils/const.dart';
import 'package:kheabia/widgets/my_drop_down_form_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class StudentAbsenceReview extends StatefulWidget {
  @override
  _StudentAbsenceReviewState createState() => _StudentAbsenceReviewState();
}

class _StudentAbsenceReviewState extends State<StudentAbsenceReview> {
  String subject = '';
  String doctorName = 'اسم الدكتور';
  String currentCount = '0';
  String numberOfTimes = '0';
  String numberOfAbsances = '0';
  final Firestore _firestore = Firestore.instance;
  List<Map<String, String>> subjects = [];

  List<Subject> subjectsData = [];

  void loadSubjects() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('Subjects')
        .getDocuments(); // fetch all subjects

    for (int i = 0; i < querySnapshot.documents.length; i++) {
      // move inside each subject
      DocumentSnapshot currentSubject = querySnapshot.documents[i];

      // fetch all students inside current subject
      QuerySnapshot studentQuerySnapshot = await _firestore
          .collection('Subjects')
          .document('${currentSubject.data['code']}')
          .collection('Students')
          .getDocuments();

      for (int j = 0; j < studentQuerySnapshot.documents.length; j++) {
        if (studentQuerySnapshot.documents[j].data['id'] ==
            Pointer.currentStudent.id) {
          Subject subject = Subject(
            name: currentSubject.data['name'],
            code: currentSubject.data['code'],
            currentCount: currentSubject.data['currentCount'],
            profID: currentSubject.data['profID'],
            profName: currentSubject.data['profName'],
            numberOfTimes:
                studentQuerySnapshot.documents[j].data['numberOfTimes'],
          );
          subjectsData.add(subject);
          subjects.add(
            {
              'display':
                  '   ${currentSubject.data['code']}         ${currentSubject.data['name']}',
              'value': currentSubject.data['name'],
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
        loadSubjects();
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
          'مراجعة الغياب',
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
              ? ListView(
                  children: <Widget>[
                    Image.asset(
                      'assets/images/2.jpg',
                      fit: BoxFit.cover,
                      height: ScreenUtil().setHeight(
                        180,
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(
                        13,
                      ),
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
                            handleSelection(value);
                          },
                          onChanged: (value) {
                            handleSelection(value);
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
                      ),
                      child: MyFadeAnimation(
                        delayinseconds: 1.5,
                        child: Container(
                          height: ScreenUtil().setHeight(40),
                          decoration: BoxDecoration(
                            color: Const.mainColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          margin: EdgeInsets.all(
                            ScreenUtil().setHeight(10),
                          ),
                          child: Center(
                            child: Text(
                              doctorName,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(16.0),
                      ),
                      child: MyFadeAnimation(
                        delayinseconds: 2,
                        child: _buildInfoField(
                          title: 'عدد المحاضرات',
                          count: '$currentCount',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(16.0),
                      ),
                      child: MyFadeAnimation(
                        delayinseconds: 2.5,
                        child: _buildInfoField(
                          title: 'عدد مرات الحضور',
                          count: '$numberOfTimes',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(16.0),
                      ),
                      child: MyFadeAnimation(
                        delayinseconds: 3,
                        child: _buildInfoField(
                          title: 'عدد مرات الغياب',
                          count: '$numberOfAbsances',
                        ),
                      ),
                    ),
                  ],
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

  Widget _buildInfoField({String title, String count}) {
    return Container(
      height: ScreenUtil().setHeight(40),
      decoration: BoxDecoration(
        color: Const.mainColor,
        borderRadius: BorderRadius.circular(30),
      ),
      margin: EdgeInsets.all(
        ScreenUtil().setHeight(10),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(
            left: ScreenUtil().setHeight(19.0),
            right: ScreenUtil().setHeight(19.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                count,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  handleSelection(value) {
    subject = value;
    for (int i = 0; i < subjectsData.length; i++) {
      if (subjectsData[i].name == subject) {
        doctorName = subjectsData[i].profName;
        currentCount = subjectsData[i].currentCount;
        numberOfTimes = subjectsData[i].numberOfTimes;

        int count = int.parse(subjectsData[i].currentCount);
        int times = int.parse(subjectsData[i].numberOfTimes);
        int absances = count - times;

        numberOfAbsances = '$absances';
      }
    }
    setState(
      () {},
    );
  }
}
