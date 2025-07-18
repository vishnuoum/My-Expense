import 'package:flutter/material.dart';
import 'package:my_expense/pages/analytics_page.dart';
import 'package:my_expense/pages/card_page.dart';
import 'package:my_expense/pages/cash_page.dart';
import 'package:my_expense/pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedPage = 0;

  void updateActivePage(int index) {
    setState(() {
      _selectedPage = index;
    });
  }

  final List<Widget> _pages = [
    CardPage(),
    CashPage(),
    AnalyticsPage(),
    SettingsPage(),
  ];

  List<BottomNavigationBarItem> getBottomNavBarItems() {
    return <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.credit_card),
        label: 'Cards',
        tooltip: "Cards",
        backgroundColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.backgroundColor,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.currency_rupee),
        label: 'Cash',
        tooltip: "Cash",
        backgroundColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.backgroundColor,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.analytics_sharp),
        label: 'Analytics',
        tooltip: "Analytics",
        backgroundColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.backgroundColor,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Settings',
        tooltip: "Settings",
        backgroundColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.backgroundColor,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedPage, children: _pages),
      bottomNavigationBar: SizedBox(
        height: 100,
        child: Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            items: getBottomNavBarItems(),
            onTap: updateActivePage,
            currentIndex: _selectedPage,
          ),
        ),
      ),
    );
  }
}
