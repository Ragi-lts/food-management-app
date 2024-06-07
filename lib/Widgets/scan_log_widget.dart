import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Helpers/datetime_helper.dart';
import '../Models/barcode_input_model.dart';
import '../Providers/barcode_input_log_provider.dart';

class ScanLogWidget extends StatelessWidget {
  const ScanLogWidget({super.key});

  Widget askClearLogDialog(BuildContext context, BarcodeInputLogProvider provider) {
    return AlertDialog(
      content: const Text("読取履歴をクリアしますか？"),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.clear();
            },
            child: const Text("はい")),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("いいえ")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BarcodeInputLogProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("読取履歴（${provider.log.length}件）"),
                OutlinedButton.icon(
                    onPressed: () =>
                        showDialog(context: context, builder: (context) => askClearLogDialog(context, provider)),
                    icon: const Icon(Icons.clear_all),
                    label: const Text("クリア"))
              ],
            ),
            Expanded(
              child: Card(
                color: Colors.brown.shade50,
                child: provider.log.isNotEmpty
                    ? ListView.separated(
                        // reverse: true,
                        itemCount: provider.log.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          BarcodeInputModel item = provider.log[index];
                          return Dismissible(
                            key: UniqueKey(),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              provider.popLog(index);
                            },
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
                              subtitle: Text("""
登録日時： ${DateTimeHelper.format(value: item.createdAt!)}
期限日　： ${DateTimeHelper.format(value: item.limitDate.toString(), format: "yyyy/MM/dd")}
"""),
                              dense: true,
                              onTap: () async {},
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
    );
  }
}
