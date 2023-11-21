class NotificationsModel {
  late String _title;
  late String _message;
  late String _time;
  late int _is_read;
  late int _division_id;
  late int _department_id;
  late int _id;

  NotificationsModel(this._id,this._title, this._message, this._time, this._is_read,
      this._division_id, this._department_id);

  int get department_id => _department_id;

  set department_id(int value) {
    _department_id = value;
  }

  int get division_id => _division_id;

  set division_id(int value) {
    _division_id = value;
  }

  int get is_read => _is_read;

  set is_read(int value) {
    _is_read = value;
  }

  String get time => _time;

  set time(String value) {
    _time = value;
  }

  String get message => _message;

  set message(String value) {
    _message = value;
  }

  String get title => _title;

  set title(String value) {
    _title = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }
}
