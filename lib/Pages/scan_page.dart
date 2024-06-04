import 'package:flutter/material.dart';
import 'package:food_management/Providers/barcode_input_provider.dart';
import 'package:food_management/Widgets/scan_log_widget.dart';
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

  Future<void> register(BuildContext context, BarcodeInputModel? model) async {
    bool isRegisterable = true;
    BarcodeInputLogProvider logProvider = context.read<BarcodeInputLogProvider>();
    List<BarcodeInputModel> list = logProvider.getLog();
    // 直前に同じバーコードを読もうとするとワーニング
    if (list.isNotEmpty && list.last.barcodeNumber == model!.barcodeNumber) {
      isRegisterable = await showReadWaringDialog(context);
    }
    if (isRegisterable) {
      model!.setBarcodeInfo(value: model.barcodeNumber);
      logProvider.pushLog(model);
      model = null;
    }
  }

  Widget inputBarcodeInfo(context, BarcodeInputProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: MediaQuery.of(context).size.width / 3, child: const Text("バーコード番号：")),
            Text(provider.getBarcodeNumber()),
          ],
        ),
        // Row(
        //   children: [
        //     SizedBox(width: MediaQuery.of(context).size.width / 3, child: const Text("バーコード番号：")),
        //     Text(provider.getBarcodeNumber()),
        //   ],
        // ),
        // Row(
        //   children: [
        //     SizedBox(width: MediaQuery.of(context).size.width / 3, child: const Text("バーコード番号：")),
        //     Text(provider.getBarcodeNumber()),
        // ],
        // )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    MobileScannerController? scannerController;
    BarcodeInputModel? model;

    return Column(
      children: [
        Consumer<BarcodeInputProvider>(builder: (context, provider, child) {
          return Column(
            children: [
              Visibility(
                visible: provider.isRunning,
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
                      scannerController?.events?.pause();
                      final Barcode code = capture.barcodes.first;
                      if (model == null && code.displayValue != null) {
                        model = BarcodeInputModel();
                        model!.setBarcodeInfo(value: code.displayValue!);
                        provider.init(model!);
                        provider.setIsRead(true);
                        debugPrint("モデル(BarcodeInputModel)を生成しました：${model!.barcodeNumber}");
                      }
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: provider.isRunning
                        ? ElevatedButton(
                            child: const Text("読み取りをやめる"),
                            onPressed: () async {
                              if (scannerController != null) {
                                scannerController!.dispose();
                              }
                              debugPrint("カメラを終了しました");
                              provider.setIsRunning(false);
                              provider.reset();
                              model = null;
                            },
                          )
                        : ElevatedButton(
                            child: const Text("読み取りをはじめる"),
                            onPressed: () async {
                              debugPrint("カメラ起動中");
                              scannerController = MobileScannerController(detectionSpeed: DetectionSpeed.normal);
                              try {
                                MobileScannerArguments? args = await scannerController!.start();
                                if (args == null) {
                                  debugPrint("カメラを起動できませんでした");
                                  return;
                                }
                                debugPrint("カメラを起動しました");
                                provider.setIsRunning(true);
                              } on MobileScannerException catch (_, err) {
                                debugPrint(err.toString());
                              }
                            },
                          )),
              ),
              // 入力結果の表示
              // 期限入力
              Visibility(
                visible: provider.isRead,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      child: inputBarcodeInfo(context, provider),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            // width: 200,
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
                          Text(
                            provider.getLimit() == null
                                ? "期限が設定されていません"
                                : DateFormat('yyyy/MM/dd').format(provider.getLimit()!),
                          ),
                        ],
                      ),
                    ),
                    // 登録する／しないボタン
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                            onPressed: provider.getLimit() != null && provider.model != null
                                ? () async => register(context, provider.model!)
                                : null,
                            child: const Text("登録する"),
                          )),
                    )
                  ],
                ),
              ),
            ],
          );
        }),
        // 読取履歴
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
          child: SizedBox(height: MediaQuery.of(context).size.height / 3, child: const ScanLogWidget()),
        )
      ],
    );
  }
}
