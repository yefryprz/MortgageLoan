import 'package:flutter/material.dart';

class CustomCard extends StatefulWidget {
  
  final String amount;
  final Function acction;
  CustomCard({Key key, this.amount, this.acction}) : super(key: key);

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Center(
            child: Container(
              padding: EdgeInsets.only(top: 15),
              child: Text("Your estimated monthly payment", style: TextStyle(fontSize: 18.0)),
            )
          ),
          SizedBox(height: 15.0),
          Text(
            widget.amount.length == 0 ? "0" :'${widget.amount}',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 50.0
            ),
          ),
          SizedBox(height: 10.0),
          TextButton(
            onPressed: widget.acction,
            child: Text("Generate Amortization", style: TextStyle(color: Colors.green, fontSize: 20.0))
          )
        ],
      ),
    );
  }
}