class UIMessage {
  String text;
  UIMessageType type;
  UIMessage(this.text, this.type);

  factory UIMessage.success(String text) {
    return UIMessage(text, UIMessageType.success);
  }

  factory UIMessage.warning(String text) {
    return UIMessage(text, UIMessageType.error);
  }

  factory UIMessage.error(String text) {
    return UIMessage(text, UIMessageType.error);
  }
}

enum UIMessageType { success, warning, error }
