import 'package:flutter/material.dart';

class CustomDateTable extends StatelessWidget {
  final List<DataRow>? rowItems;
  CustomDateTable({Key? key, this.rowItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DataTable(columns: const <DataColumn>[
      DataColumn(label: Text('No.')),
      DataColumn(label: Text('Interest')),
      DataColumn(label: Text('Principal')),
      DataColumn(label: Text('Balance'))
    ], rows: rowItems!);
  }
}
