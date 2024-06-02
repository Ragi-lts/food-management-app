import 'package:flutter/material.dart';
import 'package:food_management/Providers/barcode_input_provider.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../Helpers/datetime_helper.dart';
import '../Models/barcode_input_model.dart';
import '../Providers/barcode_input_log_provider.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  Future<bool> showReadWaringDialog(
    BuildContext context,
  ) async {
    bool isRegisterable = true;
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              icon: const Icon(Icons.warning),
              content: const Text("同じバーコードを読み取ろうとしていますが、よろしいですか？"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      isRegisterable = true;
                    },
                    child: const Text("はい")),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      isRegisterable = false;
                    },
                    child: const Text("いいえ")),
              ],
            ));
    return isRegisterable;
  }

  Future<void> register(BuildContext context, BarcodeInputProvider provider) async {
    bool isRegisterable = true;
    BarcodeInputLogProvider logProvider = context.read<BarcodeInputLogProvider>();
    List<BarcodeInputModel> list = logProvider.getLog();
    // 直前に同じバーコードを読もうとするとワーニング
    if (list.isNotEmpty && list.last.barcodeNumber == provider.getBarcodeNumber()) {
      isRegisterable = await showReadWaringDialog(context);
    }
    if (isRegisterable) {
      logProvider.pushLog(provider.model);
    }
  }

  @override
  Widget build(BuildContext context) {
    MobileScannerController? scannerController;

    return Column(
      children: [
        Consumer<BarcodeInputProvider>(builder: (context, provider, child) {
          return Column(
            children: [
              Visibility(
                visible: provider.getIsRunning(),
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: SafeArea(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height / 8,
                      child: MobileScanner(
                        controller: scannerController,
                        fit: BoxFit.cover,
                        onScannerStarted: (arguments) {
                          debugPrint("カメラ読取開始");
                          provider.setIsRunning(true);
                        },
                        onDetect: (capture) async {
                          scannerController!.events?.pause();
                          final Barcode code = capture.barcodes.first;
                          if (code.displayValue != null) {
                            provider.setBarcodeNumber(code.displayValue!);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: provider.getIsRunning()
                        ? ElevatedButton(
                            child: const Text("カメラを閉じる"),
                            onPressed: () async {
                              if (scannerController != null) {
                                scannerController!.dispose();
                              }
                              debugPrint("カメラを終了しました");
                              provider.setIsRunning(false);
                              provider.reset();
                            },
                          )
                        : ElevatedButton(
                            child: const Text("カメラを起動する"),
                            onPressed: () async {
                              debugPrint("カメラ起動中");
                              scannerController = MobileScannerController(detectionSpeed: DetectionSpeed.normal);
                              MobileScannerArguments? args = await scannerController!.start();
                              if (args == null) {
                                debugPrint("カメラを起動できませんでした");
                                return;
                              }
                              debugPrint("カメラを起動しました");
                              provider.setIsRunning(true);
                            },
                          )),
              ),
              // 入力結果の表示
              // 期限入力
              Visibility(
                visible: provider.getIsRead(),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text(provider.getBarcodeNumber()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Center(
                            child: SizedBox(
                              width: 200,
                              height: 50,
                              child: OutlinedButton.icon(
                                  onPressed: () async {
                                    DateTime? limit = await showDatePicker(
                                        initialEntryMode: DatePickerEntryMode.inputOnly,
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(const Duration(days: 100)));
                                    if (limit != null) {
                                      // 日付入力されるとセットされる
                                      provider.setLimitDate(limit);
                                    }
                                  },
                                  icon: const Icon(Icons.calendar_month),
                                  label: Text(provider.getLimit() == null ? "期限を設定する" : "期限を設定し直す")),
                            ),
                          ),
                          Text(provider.getLimit() == null
                              ? "期限が設定されていません"
                              : DateFormat('yyyy/MM/dd').format(provider.getLimit()!)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // 登録する／しないボタン
              Visibility(
                visible: provider.getIsRead(),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                          width: 150,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: provider.getIsRead() ? () async => register(context, provider) : null,
                            child: const Text("登録する"),
                          )),
                      SizedBox(
                          width: 150,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: provider.getIsRead()
                                ? () async {
                                    provider.reset();
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary),
                            child: const Text("やり直す"),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
        // 読取履歴
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 3,
            child: Consumer<BarcodeInputLogProvider>(
              builder: (context, log, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("読取履歴"),
                          OutlinedButton.icon(
                              onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        content: const Text("読取履歴をクリアしますか？"),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                log.clear();
                                              },
                                              child: const Text("はい")),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("いいえ")),
                                        ],
                                      )),
                              icon: const Icon(Icons.clear_all),
                              label: const Text("クリア"))
                        ],
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: log.log.isNotEmpty
                            ? ListView.separated(
                                // reverse: true,
                                itemCount: log.log.length,
                                separatorBuilder: (context, index) => const Divider(),
                                itemBuilder: (context, index) {
                                  BarcodeInputModel item = log.log[index];
                                  return Dismissible(
                                    key: Key(index.toString()),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (direction) => log.popLog(index),
                                    background: Container(
                                      color: const Color.fromARGB(255, 228, 130, 130),
                                      child: const Align(
                                          alignment: Alignment.centerRight,
                                          child: Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Text(
                                              "削除",
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          )),
                                    ),
                                    child: ListTile(
                                      leading: Text("${index + 1}"),
                                      title: Text(item.barcodeNumber),
                                      subtitle: Text("登録日時： ${DateTimeHelper.format(value: item.createdAt!)}"),
                                      dense: true,
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                child: Text(
                                "登録したバーコードの一覧が表示されます",
                              )),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        )
      ],
    );
  }
}
