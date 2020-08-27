import 'package:flutter/material.dart';
import 'package:mortgageloan/src/models/Loan.model.dart';
import 'package:intl/intl.dart';

class HistoryCard extends StatelessWidget {

  final Loan data;
  HistoryCard({this.data});
  
  @override
  Widget build(BuildContext context) {
    
    var f = new NumberFormat("#,###.##", "en_US");

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, "amortization", arguments: 
          Loan(
            amount: data.amount, 
            payment:data.payment, 
            rate: data.rate, 
            term: data.term
          ));
        },
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        "${f.format(data.amount)}",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18
                        ),
                      ),
                      Text("Amount")
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "${data.term}",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18
                        ),
                      ),
                      Text("term")
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "${data.rate}",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18
                        ),
                      ),
                      Text("rate")
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "${f.format(data.payment)}",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      )
    );
  }
}