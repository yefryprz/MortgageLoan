import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  
  final String label;
  final Icon suffixIcon;
  final TextInputType inputType;
  final TextEditingController inputControl;
  
  CustomInput({Key key, this.label, this.suffixIcon, this.inputType, this.inputControl });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: inputType,
      controller: inputControl,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0)
        ),
        labelText: label,
        hintText: label,
        suffixIcon: suffixIcon
      )
    );
  }
}