import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ytnavigator/flutter_ytnavigator.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tcm/components/yt_tile.dart';
import 'package:tcm/core/blocs/update/update_cubit.dart';
import 'package:tcm/core/blocs/update/update_state.dart';
import 'package:tcm/core/network/http.dart';
import 'package:tcm/pages/operate_page.dart';
import 'package:tcm/pages/statistics_page.dart';
import 'package:tcm/providers/app_provider.dart';
import 'package:tcm/utils/sp_util.dart';

class Me extends StatefulWidget {
  const Me({super.key});

  @override
  State<Me> createState() => _MeState();
}

class _MeState extends State<Me> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return BlocListener<UpdateCubit, UpdateState>(
      listener: (context, state) {
        if (state is UpdateAvailableState) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('发现新版本'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '最新版本：${state.buildVersion}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '更新内容:',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    state.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('稍后再说'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _downloadAndUpgrade(state.downloadUrl);
                  },
                  child: const Text('立即更新'),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
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
              leading: const Icon(
                HugeIcons.strokeRoundedChart,
                size: 20,
              ),
              title: '数据统计',
              onTap: () {
                NavigatorUtil.push(context, const StatisticsPage());
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
              title: '当前版本',
              onTap: () {
                if (kDebugMode || Platform.isAndroid) {
                  context.read<UpdateCubit>().checkUpdate();
                }
              },
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
      ),
    );
  }

  void _downloadAndUpgrade(String downloadUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DownloadDialog(url: downloadUrl),
    );
  }
}

class _DownloadDialog extends StatefulWidget {
  final String url;

  const _DownloadDialog({required this.url});

  @override
  State<_DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<_DownloadDialog> {
  double _progress = 0;
  String _status = '准备下载...';
  bool _isDownloading = true;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    try {
      await XHttp.instance.download(
        widget.url,
        '${(await getTemporaryDirectory()).path}/app.apk',
        onReceiveProgress: (received, total) {
          if (total <= 0) return;
          setState(() {
            _progress = received / total;
            _status = '下载中 ${(_progress * 100).toStringAsFixed(0)}%';
          });

          if (received == total) {
            setState(() {
              _isDownloading = false;
              _status = '下载完成';
            });
            const methodChannel = MethodChannel('tcm_common_method');
            methodChannel.invokeMethod('silence_install');
            Navigator.pop(context);
          }
        },
      );
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _status = '下载失败';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_status),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: _progress),
          const SizedBox(height: 16),
          if (!_isDownloading)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('关闭'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
