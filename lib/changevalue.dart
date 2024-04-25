import 'package:flutter/cupertino.dart';

class ChangeDate extends ChangeNotifier{

  int _count=0;

  setCount(int count ){
    _count=count;
    notifyListeners();
    print(count);
    print(_count);
  }

  get count{
    return _count;
  }
}
