import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kheabia/animations/fade_animation.dart';
import 'package:kheabia/models/doctor_absence_model.dart';
import 'package:kheabia/models/pointer.dart';
import 'package:kheabia/models/subject.dart';
import 'package:kheabia/providers/network_provider.dart';
import 'package:kheabia/utils/const.dart';
import 'package:kheabia/widgets/my_drop_down_form_field.dart';
import 'package:provider/provider.dart';

import 'absence_details.dart';

class DoctorAbsenceReview extends StatefulWidget {
  @override
  _DoctorAbsenceReviewState createState() => _DoctorAbsenceReviewState();
}

class _DoctorAbsenceReviewState extends State<DoctorAbsenceReview> {
  List<Map<String, String>> subjects = [];
  List<DoctorAbsenceModel> students = List();
  List<Subject> subjectsData = [];
  final Firestore _firestore = Firestore.instance;
  String subject = '';

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
              ? Column(
                  children: <Widget>[
                    Hero(
                      tag: 'assets/images/2.jpg',
                      child: Image.asset(
                        'assets/images/2.jpg',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: ScreenUtil().setHeight(
                          180,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(
                        13,
                      ),
                    ),
                    subjects.isEmpty
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Padding(
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
                    Expanded(
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: Icon(
                                Icons.person,
                                color: Const.mainColor,
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DoctorAbsenceDetails(
                                      std: students[index],
                                    ),
                                  ),
                                );
                              },
                              subtitle: Text(
                                'اخر محاضرة بتاريخ  ${students[index].lastAttendance}',
                                textAlign: TextAlign.right,
                              ),
                              title: Text(
                                '${students[index].std_name}',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider(
                            height: 5,
                            color: Const.mainColor,
                          );
                        },
                        itemCount: students.length,
                      ),
                    )
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

  void handleSelection(value) async {
    subject = value;
    students.clear();
    setState(() {});

    print(subject);

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

      print(model.toMap());
      students.add(model);
    }

    setState(() {});
  }
}
