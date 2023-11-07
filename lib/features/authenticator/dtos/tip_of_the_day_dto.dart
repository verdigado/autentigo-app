class TipOfTheDayDto {
  String title;
  String text;
  String? iconPath;
  String? buttonText;
  String? url;

  TipOfTheDayDto({
    required this.title,
    required this.text,
    this.iconPath,
    this.buttonText,
    this.url,
  });
}
