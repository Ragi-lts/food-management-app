import 'package:flutter/material.dart';
import 'package:food_management/Enums/home_tab_enum.dart';
import 'package:food_management/Pages/dash_board.dart';
import 'package:food_management/Pages/my_page.dart';
import 'package:food_management/Providers/barcode_input_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'Pages/scan_page.dart';
import 'Providers/barcode_input_log_provider.dart';
import 'package:provider/provider.dart';


void main() {
  initializeDateFormatting().then((_) => runApp(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BarcodeInputProvider()),
          ChangeNotifierProvider(create: (_) => BarcodeInputLogProvider()),
        ],
        child: const MyApp(),
      )));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.brown, fontFamily: "Noto Sans JP"),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class HomePageTab {
  HomePageTab({required this.title, required this.content, required this.bottomNavBarItem});
  String title;
  Widget? content;
  BottomNavigationBarItem bottomNavBarItem;
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;
  HomeTab tab = HomeTab.dashBoard;

  List<HomePageTab> getHomePageTabInfo() {
    List<HomePageTab> info = [];
    info.addAll([
      HomePageTab(
          title: "ダッシュボード",
          content: const DashBoardPage(),
          bottomNavBarItem: const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined), label: "ダッシュボード", activeIcon: Icon(Icons.dashboard_rounded))),
      HomePageTab(
          title: "バーコード読み取り",
          content: const ScanPage(),
          bottomNavBarItem: const BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_outlined), label: '読み取る', activeIcon: Icon(Icons.camera_alt_rounded))),
      HomePageTab(
          title: "マイページ",
          content: const MyPage(),
          bottomNavBarItem: const BottomNavigationBarItem(
              icon: Icon(Icons.face_outlined), label: "マイページ", activeIcon: Icon(Icons.face_rounded)))
    ]);
    assert(info.length >= 2);
    return info;
  }

  @override
  Widget build(BuildContext context) {
    List<HomePageTab> tabInfo = getHomePageTabInfo();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(tabInfo[currentIndex].title),
      ),
      body: tabInfo[currentIndex].content,
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          selectedFontSize: 18,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: tabInfo.map((e) => e.bottomNavBarItem).toList()),
    );
  }
}
