import 'package:flutter/material.dart';
import 'package:mortgageloan/src/database/hive.dart';
import 'package:mortgageloan/src/models/loan_model.dart';
import 'package:mortgageloan/src/models/compound_interest_model.dart';
import 'package:mortgageloan/src/widgets/adbanner_widget.dart';
import 'package:mortgageloan/src/widgets/drawer_widget.dart';
import 'package:mortgageloan/src/widgets/compound_interest_historycard_widget.dart';
import 'package:mortgageloan/src/widgets/loan_history_card.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final loanRepo = LoanData();

  void _showDeleteItemConfirmation(
      BuildContext context, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Record'),
        content: Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: const Text("Calculation History"),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.white,
            tabs: [
              Tab(text: 'Loans'),
              Tab(text: 'Compound Interest'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: () => _showDeleteConfirmation(context),
            )
          ],
        ),
        drawer: CustomDrawer(),
        body: TabBarView(
          children: [
            _buildLoanHistory(),
            _buildCompoundHistory(),
          ],
        ),
        bottomNavigationBar: CustomAdBanner(),
      ),
    );
  }

  Widget _buildLoanHistory() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.history, color: Colors.teal),
              SizedBox(width: 12),
              Text(
                'Recent Calculations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Loan>>(
            future: loanRepo.selectRecords(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.data?.isEmpty ?? true) {
                return Center(
                  child: Text(
                    'No loan history yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = snapshot.data![index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          'amortization',
                          arguments: item,
                        );
                      },
                      child: LoanHistoryCard(
                        data: item,
                        onDelete: () {
                          final deletedItem = item;
                          _showDeleteItemConfirmation(
                            context,
                            () {
                              setState(() {
                                loanRepo.deleteRecord(deletedItem.id);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Record deleted'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () {
                                      setState(() {
                                        loanRepo.insertRecord(deletedItem);
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompoundHistory() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.calculate, color: Colors.teal),
              SizedBox(width: 12),
              Text(
                'Recent Calculations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<CompoundInterest>>(
            future: loanRepo.getCompoundInterestHistory(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.data!.isEmpty) {
                return Center(
                  child: Text('No compound interest calculations yet'),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data![index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        CompoundInterestHistoryCard(data: item),
                        Divider(height: 1),
                        TextButton.icon(
                          icon: Icon(Icons.delete_outline,
                              color: Colors.red[400], size: 20),
                          label: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red[400]),
                          ),
                          onPressed: () {
                            final deletedItem = snapshot.data![index];
                            _showDeleteItemConfirmation(
                              context,
                              () {
                                setState(() {
                                  loanRepo
                                      .deleteCompoundInterest(deletedItem.id);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Record deleted'),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () {
                                        setState(() {
                                          loanRepo.saveCompoundInterest(
                                              deletedItem);
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear History'),
        content: Text('Are you sure you want to delete all records?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              setState(() {
                loanRepo.deleteAllRecord();
                loanRepo.deleteAllCompoundInterest();
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
