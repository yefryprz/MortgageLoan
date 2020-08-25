import 'package:flutter/material.dart';

class CustomDateTable extends StatefulWidget {
  
  final List<DataRow> rowItems;

  CustomDateTable({Key key,  this.rowItems}) : super(key: key);

  @override
  _CustomDateTableState createState() => _CustomDateTableState();
}

class _CustomDateTableState extends State<CustomDateTable> {
  static const int numItems = 10;
  List<bool> selected = List<bool>.generate(numItems, (index) => false);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        columns: const <DataColumn>[
          DataColumn(
            label: Text('No.')
          ),
          DataColumn(
            label: Text('Interest')
          ),
          DataColumn(
            label: Text('Principal')
          ),
          DataColumn(
            label: Text('Balance')
          )
        ],
        rows: widget.rowItems
      ),
    );
  }
}