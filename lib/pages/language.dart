import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tcm/components/yt_tile.dart';
import 'package:tcm/i18n/i18n.dart';
import 'package:tcm/store.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LanguagePageState();
  }
}

class _LanguagePageState extends State<LanguagePage> {
  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    LocaleStore localeModel = context.watch<LocaleStore>();
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).settingsLanguage)),
      body: ListView(
        children: List<Widget>.of(
          S.localeSets.keys.map(
            (key) => YTTile(
              title: S.localeSets[key]!,
              trailing: localeModel.languageCode == key
                  ? Icon(Icons.done, color: color)
                  : null,
              onTap: () {
                localeModel.setLanguageCode(key);
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }
}
