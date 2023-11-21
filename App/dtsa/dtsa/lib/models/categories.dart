class Categories{


  late int _department_category_id;
  late String _name;
  late int _division_id;
  late int _department_id;


  Categories(this._department_category_id, this._name, this._division_id,
      this._department_id);

  int get department_id => _department_id;

  set department_id(int value) {
    _department_id = value;
  }

  int get division_id => _division_id;

  set division_id(int value) {
    _division_id = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  int get department_category_id => _department_category_id;

  set department_category_id(int value) {
    _department_category_id = value;
  }
}