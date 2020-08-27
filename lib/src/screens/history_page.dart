import 'package:flutter/material.dart';
import 'package:mortgageloan/src/database/load.data.dart';
import 'package:mortgageloan/src/models/Loan.model.dart';
import 'package:mortgageloan/src/widgets/drawler_widget.dart';
import 'package:mortgageloan/src/widgets/historycard_widget.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final loanRepo = LoanData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete), 
            onPressed: () {
              setState(() {
                loanRepo.deleteAllRecord();
              });
            }
          )
        ],
      ),
      drawer: CustomDrawler(),
      body: FutureBuilder(
        future: loanRepo.selectRecords(),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                final record = snapshot.data[index] as Loan;
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart, 
                  child: HistoryCard(data: record),
                  onDismissed: (direction) {
                    setState(() {
                      loanRepo.deleteRecord(record.id);
                    });
                  },
                  background: Container(
                    color: Colors.red,
                    child: Center(
                      child: Text(
                        "Delete",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                      ),
                    )
                  ),
                );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator()
            );
          }
        },
      ),
    );
  }
}