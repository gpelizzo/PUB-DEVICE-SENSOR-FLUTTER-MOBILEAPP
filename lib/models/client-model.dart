class ClientModel {
  String strId;
  String strNickName;

  ClientModel.fromClientModel() {
    this.strId = '';
    this.strNickName = '';
  }

  ClientModel(this.strId, this.strNickName);

  bool isEmpty() {
    return this.strId.isEmpty;
  }
}
