import 'package:flutter/material.dart';
import 'package:mortgageloan/src/models/loan_model.dart';
import 'package:intl/intl.dart';

class HistoryCard extends StatelessWidget {
  final Loan? data;
  const HistoryCard({this.data});

  @override
  Widget build(BuildContext context) {
    var nFormat = NumberFormat("#,###.##", "en_US");
    return Card(
        child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, "amortization",
                  arguments: Loan(
                      amount: data!.amount,
                      payment: data!.payment,
                      rate: data!.rate,
                      term: data!.term));
            },
            child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _info("Amount", nFormat.format(data!.amount)),
                        _info("Term", nFormat.format(data!.term)),
                        _info("Rate", data!.rate.toString()),
                        Column(children: [
                          Text(nFormat.format(data!.payment),
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 18)),
                        ])
                      ])
                ]))));
  }

  Widget _info(String title, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.grey, fontSize: 15)),
        Text(title)
      ],
    );
  }
}
