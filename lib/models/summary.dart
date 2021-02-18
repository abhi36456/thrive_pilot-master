class Summary {
  Summary({
    this.focus,
    this.meditate,
  });

  Data focus;
  Data meditate;

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    focus: Data.fromJson(json["focus"]),
    meditate: Data.fromJson(json["meditate"]),
  );

  Map<String, dynamic> toJson() => {
    "focus": focus.toJson(),
    "meditate": meditate.toJson(),
  };
}

class Data {
  Data({
    this.today,
    this.thisWeek,
    this.thisMonth,
    this.all,
  });

  String today;
  String thisWeek;
  String thisMonth;
  String all;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    today: json["today"],
    thisWeek: json["this_week"],
    thisMonth: json["this_month"],
    all: json["all"],
  );

  Map<String, dynamic> toJson() => {
    "today": today,
    "this_week": thisWeek,
    "this_month": thisMonth,
    "all": all,
  };
}
