import 'package:flutter/material.dart';
import 'package:flutter_ytnavigator/flutter_ytnavigator.dart';
import 'package:tcm/components/yt_tile.dart';
import 'package:tcm/i18n/i18n.dart';
import 'package:tcm/pages/contact_list_page.dart';
import 'package:tcm/pages/order_list_page.dart';

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
            title: '客户管理',
            onTap: () {
              NavigatorUtil.push(context, const ContactListPage());
            },
          ),
          YTTile(
            title: '药品管理',
            onTap: () {},
          ),
          YTTile(
            title: '处方管理',
            onTap: () {
              NavigatorUtil.push(context, const OrderListPage());
            },
          ),
        ],
      ),
    );
  }
}
