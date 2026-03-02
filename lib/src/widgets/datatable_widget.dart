import 'package:flutter/material.dart';

class CustomDataTable extends StatelessWidget {
  final List<DataRow> rowItems;

  const CustomDataTable({Key? key, required this.rowItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Fixed header
        Container(
          color: Colors.grey[200],
          child: Row(
            children: [
              _buildHeaderCell('Month', 60),
              _buildHeaderCell('Payment', 120),
              _buildHeaderCell('Principal', 120),
              _buildHeaderCell('Interest', 120),
              _buildHeaderCell('Balance', 120),
            ],
          ),
        ),
        // Scrollable content
        SingleChildScrollView(
          child: DataTable(
            headingRowHeight: 0,
            columnSpacing: 20,
            columns: const [
              DataColumn(label: SizedBox(width: 40)),
              DataColumn(label: SizedBox(width: 100)),
              DataColumn(label: SizedBox(width: 100)),
              DataColumn(label: SizedBox(width: 100)),
              DataColumn(label: SizedBox(width: 100)),
            ],
            rows: rowItems,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
