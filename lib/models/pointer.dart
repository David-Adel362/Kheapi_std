import 'package:kheabia/models/doctor.dart';
import 'package:kheabia/models/doctor_absence_model.dart';
import 'package:kheabia/models/student.dart';

class Pointer {
  static Student currentStudent = Student();
  static Doctor currentDoctor = Doctor();
  static DoctorAbsenceModel currentAbsence = DoctorAbsenceModel();
}
