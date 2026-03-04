import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CustomDrawer extends StatefulWidget {
  final String currentRoute;

  const CustomDrawer({Key? key, required this.currentRoute}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String _appVersion = "";

  @override
  void initState() {
    super.initState();
    getAppVersion();
  }

  Future<void> getAppVersion() async {
    final appInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = appInfo.version;
    });
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
  }) {
    final bool isActive = widget.currentRoute == route;

    return InkWell(
      onTap: () {
        if (!isActive) {
          Navigator.popAndPushNamed(context, route);
        } else {
          Navigator.pop(context);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 24, bottom: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE6F7F5) : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          border: isActive
              ? const Border(
                  left: BorderSide(color: Color(0xFF3ac0b5), width: 4),
                )
              : const Border(
                  left: BorderSide(color: Colors.transparent, width: 4),
                ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : const Color(0xFFF8FAFC),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF3ac0b5),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF475569),
                fontSize: 16,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width,
      backgroundColor: Colors.white,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 60, bottom: 40),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3ac0b5), Color(0xFF27a9bf)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withAlpha(51), // 20% opacity white
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage("assets/logo.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Mortgage Loan",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Version: ${_appVersion.isEmpty ? '1.1.2' : _appVersion}",
                          style: TextStyle(
                            color: Colors.white.withAlpha(204), // 80% opacity
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.calculate,
                    title: "Calculate Loan",
                    route: "/",
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: CupertinoIcons.lab_flask,
                    title: "Loan Simulator",
                    route: "simulator",
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.trending_up,
                    title: "Compound Interest",
                    route: "compound",
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.currency_exchange,
                    title: "Currency Converter",
                    route: "currency",
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.history,
                    title: "History",
                    route: "history",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
