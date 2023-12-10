import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String? label;
  final Icon? suffixIcon;
  final TextInputType? inputType;
  final TextEditingController? inputControl;

  const CustomInput(
      {Key? key,
      this.label,
      this.suffixIcon,
      this.inputType,
      this.inputControl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, top: 5),
      child: TextField(
          keyboardType: inputType,
          controller: inputControl,
          decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              labelText: label,
              hintText: label,
              suffixIcon: suffixIcon)),
    );
  }
}
