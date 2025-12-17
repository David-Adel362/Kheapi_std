class Subject {
  String name;
  String code;
  String currentCount;
  String numberOfTimes;
  String numberOfAbsances;
  String profName;
  String profID;

  Subject({
    name,
    code,
    currentCount,
    numberOfTimes,
    numberOfAbsences,
    profName,
    profID,
  }) {
    this.name = name;
    this.code = code;
    this.currentCount = currentCount;
    this.numberOfTimes = numberOfTimes;
    this.numberOfAbsances = numberOfAbsances;
    this.profName = profName;
    this.profID = profID;
  }

  String get getName => name;

  set setName(String name) => this.name = name;

  String get getCode => code;

  set setCode(String code) => this.code = code;

  String get getCurrentCount => currentCount;

  set setCurrentCount(String currentCount) => this.currentCount = currentCount;

  set setNumberOfTimes(String numberOfTimes) =>
      this.numberOfTimes = numberOfTimes;

  String get getNumberOfTimes => numberOfTimes;

  set setNumberOfAbsances(String numberOfAbsances) =>
      this.numberOfAbsances = numberOfAbsances;

  String get getNumberOfAbsances => numberOfAbsances;

  String get getProfName => profName;

  set setProfName(String profName) => this.profName = profName;

  String get getProfID => profID;

  set setProfID(String profID) => this.profID = profID;
}
