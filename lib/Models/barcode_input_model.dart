class BarcodeInputModel  {
  bool isRunning = false; //バーコード読み取り中
  String barcodeNumber = '';  // 読み取ったバーコード番号
  bool isRead = false;  // 読取済みか否か
  DateTime? limit;  // 期限日
  String? createdAt;  //  作成日時



// 初期化する
  void init() {
    barcodeNumber = '';
    isRead = false;
    limit = null;
  }

  // バーコードをセットする
  void setBarcodeNumber(String value) {
    barcodeNumber = value;
    isRead = true;
    createdAt = DateTime.now().toString();
  }

  // 期限をセットする
  void setLimitDate(DateTime value) {
    limit = value;
  }

  void setIsRunning(bool value) {
    isRunning = value;
  }

}
