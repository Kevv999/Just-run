//Class contaning data used to make the charts generic.

class Settings {
  String chartType;
  String duration;
  String bottomTitle;
  String leftTitle;
  String topTitle;
  String toolTipUnit;
  int xAxis;

  Settings(
      {required this.chartType,
      required this.xAxis,
      required this.duration,
      required this.bottomTitle,
      required this.leftTitle,
      required this.topTitle,
      required this.toolTipUnit});
}
