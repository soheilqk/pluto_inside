import 'package:flutter/material.dart';

class MyCheckBox extends StatelessWidget {
//
  //final String label;
  final bool checkExpr;
  final Function onChange;

  const MyCheckBox({
    //@required this.label,
    @required this.checkExpr,
    @required this.onChange,
  });

  Image get checkIcon => checkExpr == null
      ? Image.asset('assets/images/icons/checkBoxEmpty.png')
      : checkExpr
      ? Image.asset('assets/images/icons/checkBoxFilled.png')
      : Image.asset('assets/images/icons/checkBoxEmpty.png');

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      textBaseline: TextBaseline.alphabetic,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            var value = checkExpr == null ? true : !checkExpr;
            onChange(value);
          },
          child: SizedBox(
            height: 14,
            width: 14,
            child: checkIcon,
          ),
        ),
      ],
    );
  }
}
