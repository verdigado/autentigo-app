import 'package:flutter/material.dart';
import 'package:kc_auth_app/app/constants/image_paths.dart';
import '../dtos/tip_of_the_day_dto.dart';

class TipOfTheDayModel extends ChangeNotifier {
  List<TipOfTheDayDto> _tips = [];
  int _curretIndex = 0;

  TipOfTheDayModel() {
    _init();
  }

  Future<void> _init() async {
    _tips = await _fetchTips();
    notifyListeners();
  }

  TipOfTheDayDto? get current {
    if (_tips.isEmpty) {
      return null;
    }
    return _tips[_curretIndex];
  }

  void next() {
    if (_tips.isNotEmpty) {
      _curretIndex = (_curretIndex + 1) % _tips.length;
      notifyListeners();
    }
  }

  Future<List<TipOfTheDayDto>> _fetchTips() async {
    var tips = [
      TipOfTheDayDto(
        title: 'Wolke Decks',
        text:
            'In der Wolke könnt ihr jetzt auch gemeinsam zeitgleich an Decks arbeiten, um eure Projekte zu organisieren.',
        iconPath: imageUndrawArticles,
        url: 'https://wolke.netzbegruenung.de',
        buttonText: 'zur Wolke',
      ),
      TipOfTheDayDto(
        title: 'Für die Grünen',
        text:
            'Kandidierende aufgepasst: Auf fuer-die-gruenen.de könnt ihr euch kostenlos eine eigene Web-Präsenz einrichten.',
        iconPath: imageUndrawOnlineStats,
        url: 'https://fuer-die-gruenen.de',
      ),
      TipOfTheDayDto(
        title: 'Video-Konferzen',
        text:
            'Auf der neuen Seite meet.gruene.de könnt ihr ab sofort Video-Konferenzen starten.',
        iconPath: imageUndrawReminder,
        url: 'https://meet.gruene.de',
      ),
      TipOfTheDayDto(
        title: 'Chatbegrünung',
        text:
            'Ihr habt eine Frage oder ein Problem mit einer grünen Anwendung? In der Chatbegrünung könnt ihr euch im jeweiligen Kanal austauschen und findet Informationen zu Anleitungen und Support.',
        iconPath: imageUndrawArticles,
        url: 'https://chatbegruenung.de',
      ),
      TipOfTheDayDto(
        title: 'Wordpress Sunflower',
        text:
            'Auf sunflower-theme.de könnt ihr kostenlos die grüne Optik für WordPress-Webseiten herunterladen.',
        iconPath: imageUndrawOnlineStats,
        url: 'https://sunflower-theme.de',
      ),
      TipOfTheDayDto(
        title: 'Grünlink',
        text:
            'Auf grünlink.de kannst du lange Links auf eine angenehmere Länge verkürzen.',
        iconPath: imageUndrawReminder,
        url: 'https://grünlink.de',
      ),
      // TipOfTheDayDto(
      //   title: 'QR-Codes',
      //   text: 'Auf service.gruene.de/qrcode/ kannst du Links in QR-Codes umwandeln, die sich mit dem Smartphone und Tablet scannen lassen.',
      //   iconPath: 'assets/images/undraw_articles_wbpb.svg',
      //   url: 'https://service.gruene.de/qrcode/ ',
      // ),
      TipOfTheDayDto(
        title: 'Livestreams',
        text:
            'Mit dem Livestream-Koffer unserer IT-Genossenschaft verdigado könnt ihr unkompliziert Livestreams übertragen.',
        iconPath: imageUndrawTeamUp,
      ),
      TipOfTheDayDto(
        title: 'Polls',
        text:
            'Ab sofort kannst du in der Wolke die Polls-App für Umfragen nutzen. Sie wird bald die Termite ablösen, vorerst könnt ihr beide Dienste nutzen.',
        iconPath: imageUndrawReminder,
      ),
    ];
    return tips;
  }
}
