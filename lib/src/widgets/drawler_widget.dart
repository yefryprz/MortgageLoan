import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CustomDrawler extends StatefulWidget {
  @override
  State<CustomDrawler> createState() => _CustomDrawlerState();
}

class _CustomDrawlerState extends State<CustomDrawler> {
  String _appVersion = "";

  @override
  void initState() {
    super.initState();
    getAppVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        color: Theme.of(context).primaryColor,
        child: Center(
          child: Column(
            children: [
              Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(top: 30, bottom: 10),
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: AssetImage("assets/logo.png"),
                          fit: BoxFit.fill))),
              const Text("Mortgage Loan",
                  style: TextStyle(fontSize: 25, color: Colors.white)),
              Text("Version: $_appVersion",
                  style: const TextStyle(color: Colors.white))
            ],
          ),
        ),
      ),
      ListTile(
          onTap: () => Navigator.popAndPushNamed(context, "/"),
          leading: Icon(Icons.keyboard, color: Theme.of(context).primaryColor),
          title: Text("Calculate Loan",
              style: TextStyle(color: Colors.grey[700], fontSize: 18))),
      ListTile(
          onTap: () => Navigator.popAndPushNamed(context, "history"),
          leading: Icon(Icons.history, color: Theme.of(context).primaryColor),
          title: Text("History",
              style: TextStyle(color: Colors.grey[700], fontSize: 18)))
    ]));
  }

  Future<void> getAppVersion() async {
    final appInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = appInfo.version;
    });
  }
}
