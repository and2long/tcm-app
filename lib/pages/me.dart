import 'package:flutter/material.dart';
import 'package:flutter_ytnavigator/flutter_ytnavigator.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:tcm/components/yt_tile.dart';
import 'package:tcm/pages/operate_page.dart';
import 'package:tcm/providers/app_provider.dart';
import 'package:tcm/utils/sp_util.dart';

class Me extends StatelessWidget {
  const Me({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
      ),
      body: ListView(
        children: [
          YTTile(
            leading: const Icon(
              HugeIcons.strokeRoundedUserSwitch,
              size: 20,
            ),
            title: '切换为药房端',
            onTap: () {
              SPUtil.saveIsDoctor(false);
              NavigatorUtil.pushReplacement(context, const OperatePage());
            },
          ),
          YTTile(
            title: '主题设置',
            trailing: DropdownButton<ThemeMode>(
              value: provider.themeMode,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('跟随系统'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('浅色'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('深色'),
                ),
              ],
              onChanged: (ThemeMode? mode) {
                if (mode != null) {
                  provider.setThemeMode(mode);
                }
              },
            ),
          ),
          YTTile(
            title: '版本',
            trailing: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: ((
                BuildContext context,
                AsyncSnapshot<PackageInfo> snapshot,
              ) {
                String version = '';
                if (snapshot.hasData) {
                  version =
                      '${snapshot.data!.version} (${snapshot.data!.buildNumber})';
                }
                return Text(
                  version,
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
