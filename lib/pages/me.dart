import 'package:flutter/material.dart';
import 'package:flutter_ytnavigator/flutter_ytnavigator.dart';
import 'package:tcm/components/yt_tile.dart';
import 'package:tcm/i18n/i18n.dart';
import 'package:tcm/pages/language.dart';

class Me extends StatelessWidget {
  const Me({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).me),
      ),
      body: ListView(
        children: [
          YTTile(
            title: S.of(context).settingsLanguage,
            onTap: () {
              NavigatorUtil.push(context, const LanguagePage());
            },
          ),
          YTTile(
            title: S.of(context).privacyPolicy,
            onTap: () {},
          ),
          YTTile(
            title: S.of(context).termsOfService,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
