import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => BarcodeInputModel()),
      ChangeNotifierProvider(create: (_) => BarCodeInputLog())
    ],
    child: const MyApp(),
  ));
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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  void onDetect(BarcodeCapture capture) {}

  @override
  Widget build(BuildContext context) {
    MobileScannerController scannerController =
        MobileScannerController(detectionSpeed: DetectionSpeed.normal);

    return Scaffold(
      appBar: AppBar(
        title: const Text("バーコード読み取り"),
      ),
      body: Column(
        children: [
          Consumer<BarcodeInputModel>(builder: (context, barcode, child) {
            return Column(
              children: [
                Visibility(
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height / 6,
                      child: MobileScanner(
                        controller: scannerController,
                        fit: BoxFit.cover,
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          if (barcodes.isNotEmpty &&
                              barcodes.first.displayValue!.isNotEmpty) {
                            barcode
                                .setBarcodeNumber(barcodes.first.displayValue!);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                // 入力結果の表示
                Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(barcode.barcodeNumber)),
                // 期限入力
                Visibility(
                  visible: barcode.isRead,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Center(
                          child: SizedBox(
                            width: 200,
                            height: 50,
                            child: OutlinedButton.icon(
                                onPressed: () async {
                                  DateTime? limit = await showDatePicker(
                                      initialEntryMode:
                                          DatePickerEntryMode.inputOnly,
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now()
                                          .add(const Duration(days: 100)));
                                  if (limit != null) {
                                    // 日付入力されるとセットされる
                                    barcode.setLimitDate(limit);
                                  }
                                },
                                icon: const Icon(Icons.calendar_month),
                                label: Text(barcode.limit == null
                                    ? "期限を設定する"
                                    : "期限を設定し直す")),
                          ),
                        ),
                        Text(barcode.limit == null
                            ? "期限が設定されていません"
                            : DateFormat('yyyy/MM/dd').format(barcode.limit!)),
                      ],
                    ),
                  ),
                ),
                // 登録する／しないボタン
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                          width: 150,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: barcode.isRead
                                ? () => context
                                    .read<BarCodeInputLog>()
                                    .pushLog(barcode)
                                : null,
                            child: const Text("登録する"),
                          )),
                      SizedBox(
                          width: 150,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                barcode.isRead ? () => barcode.init() : null,
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary),
                            child: const Text("やり直す"),
                          )),
                    ],
                  ),
                ),
              ],
            );
          }),
          // 読取履歴
          Consumer<BarCodeInputLog>(
            builder: (context, log, child) {
              return Expanded(
                child: ListView.separated(
                  reverse: true,
                  itemCount: log.log.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    BarcodeInputModel item = log.log[index];
                    return ListTile(
                      title: Text(item.barcodeNumber),
                      subtitle: Text(DateFormat('yyyy/MM/dd HH:mm:ss').format(item.createdAt!)),
                      dense: true,
                    );
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class BarCodeInputLog extends ChangeNotifier {
  List<BarcodeInputModel> log = [];

  void pushLog(BarcodeInputModel model) {
    log.add(model);
    debugPrint(log.length.toString());
    notifyListeners();
  }

  void popLog(int index) {
    log.removeAt(index);
    notifyListeners();
  }
}

class BarcodeInputModel extends ChangeNotifier {
  String barcodeNumber = '';
  bool isRead = false;
  DateTime? limit;
  DateTime? createdAt;

// 初期化する
  void init() {
    barcodeNumber = '';
    isRead = false;
    limit = null;

    notifyListeners();
  }

  // バーコードをセットする
  void setBarcodeNumber(String value) {
    barcodeNumber = value;
    isRead = true;
    createdAt = DateTime.now();
    notifyListeners();
  }

  // 期限をセットする
  void setLimitDate(DateTime value) {
    limit = value;
    notifyListeners();
  }

  bool getIsRead() {
    return isRead;
  }
}
