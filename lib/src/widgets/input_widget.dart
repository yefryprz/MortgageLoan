import 'package:flutter/material.dart';

class CustomInput extends StatefulWidget {

  final String label;
  final Icon suffixIcon;
  final TextInputType inputType;
  final TextEditingController inputControl;
  
  CustomInput({Key key, this.label, this.suffixIcon, this.inputType, this.inputControl });

  @override
  _CustomInputState createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: widget.inputType,
      controller: widget.inputControl,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0)
        ),
        labelText: widget.label,
        hintText: widget.label,
        suffixIcon: widget.suffixIcon
      )
    );
  }
}