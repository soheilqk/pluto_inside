import 'package:flutter/material.dart';
import 'package:pluto_inside/src/widgets/checkBox.dart';

class PlutoScaledCheckbox extends StatelessWidget {
  final bool value;

  final Function(bool changed) handleOnChanged;

  final bool tristate;

  final double scale;

  final Color unselectedColor;

  final Color activeColor;

  final Color checkColor;

  const PlutoScaledCheckbox({
    Key key,
    @required this.value,
    @required this.handleOnChanged,
    this.tristate = false,
    this.scale = 1.0,
    this.unselectedColor = Colors.black26,
    this.activeColor = Colors.lightBlue,
    this.checkColor = const Color(0x00ffffff),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Theme(
        data: ThemeData(
          unselectedWidgetColor: unselectedColor,
        ),
        child: MyCheckBox(checkExpr:value,onChange:handleOnChanged,),
        // Checkbox(
        //   value: value,
        //   tristate: tristate,
        //   onChanged: handleOnChanged,
        //   activeColor: value == null ? unselectedColor : activeColor,
        //   checkColor: checkColor,
        // ),
      ),
    );
  }
}
