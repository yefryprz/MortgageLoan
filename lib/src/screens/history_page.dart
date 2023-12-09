import 'package:flutter/material.dart';
import 'package:mortgageloan/src/database/hive.dart';
import 'package:mortgageloan/src/models/loan_model.dart';
import 'package:mortgageloan/src/widgets/adbanner_widget.dart';
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
        title: const Text("History"),
        actions: [
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => setState(() {
                    loanRepo.deleteAllRecord();
                  }))
        ],
      ),
      drawer: CustomDrawler(),
      body: FutureBuilder<List<Loan>>(
        future: loanRepo.selectRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, int index) {
              return Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  setState(
                      () => loanRepo.deleteRecord(snapshot.data![index].id));
                },
                background: Container(
                    padding: const EdgeInsets.only(right: 10),
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_forever_sharp, color: Colors.white),
                        Text(
                          "Delete",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        )
                      ],
                    )),
                child: HistoryCard(data: snapshot.data![index]),
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomAdBanner(),
    );
  }
}
