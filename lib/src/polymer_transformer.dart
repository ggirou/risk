part of risk;

class StringToInt extends Transformer<String, int> {
  String forward(int i) => '$i';
  int reverse(String s) => int.parse(s);
}