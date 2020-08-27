import 'package:flutter/material.dart';

class CustomDrawler extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            color: Theme.of(context).primaryColor,
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(top: 30, bottom: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage("assets/logo.png"),
                        fit: BoxFit.fill
                      )
                    ),
                  ),
                  Text(
                    "Mortgage Loan",
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white
                    )
                  ),
                  Text(
                    "Version: 1.0.3",
                    style: TextStyle(
                      color: Colors.white
                    )
                  )
                ],
              ),
            ),
          ),
          ListTile(
            onTap: () => Navigator.popAndPushNamed(context, "/"),
            leading: Icon(Icons.keyboard, color: Theme.of(context).primaryColor),
            title: Text(
              "Calculate Loan",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 18
              ),
            ),
          ),
          ListTile(
            onTap: () => Navigator.popAndPushNamed(context, "history"),
            leading: Icon(Icons.history, color: Theme.of(context).primaryColor),
            title: Text(
              "History",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 18
              ),
            ),
          )
        ],
      ),
    );
  }
}