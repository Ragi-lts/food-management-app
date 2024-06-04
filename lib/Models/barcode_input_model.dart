import 'package:uuid/uuid.dart';

class BarcodeInputModel {
  String? id;
  String barcodeNumber = ''; // 読み取ったバーコード番号
  DateTime? limitDate; // 期限日
  String? createdAt; //  作成日時

  // バーコードをセットする
  void setBarcodeInfo({required String value, DateTime? now}) {
    id = const Uuid().v4();
    barcodeNumber = value;
    createdAt = now != null ? now.toString() : (DateTime.now()).toString();
  }

  // 期限をセットする
  void setLimitDate(DateTime value) {
    limitDate = value;
  }
}
