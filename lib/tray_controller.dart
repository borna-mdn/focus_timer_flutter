import 'dart:io' show Platform;
import 'package:system_tray/system_tray.dart';

typedef VoidCallback = void Function();

class TrayController {
  final SystemTray _tray = SystemTray();
  final AppWindow _appWindow = AppWindow();
  late final Menu _menu;

  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;

  TrayController({
    required this.onStart,
    required this.onPause,
    required this.onReset,
  });

  Future<void> init({String initialTitle = "00:00"}) async {
    if (!Platform.isMacOS) return;

    await _tray.initSystemTray(
      title: initialTitle,
      iconPath: "assets/images/timerTemplate.pdf",
    );

    _menu = Menu();
    await _menu.buildFrom([
      MenuItemLabel(label: 'Start', onClicked: (_) => onStart()),
      MenuItemLabel(label: 'Pause', onClicked: (_) => onPause()),
      MenuItemLabel(label: 'Reset', onClicked: (_) => onReset()),
      MenuSeparator(),
      MenuItemLabel(label: 'Show Window', onClicked: (_) => _appWindow.show()),
      MenuItemLabel(label: 'Quit', onClicked: (_) => _appWindow.close()),
    ]);

    await _tray.setContextMenu(_menu);

    _tray.registerSystemTrayEventHandler((eventName) async {
      if (eventName == kSystemTrayEventClick) {
        await _tray.popUpContextMenu();
      }
    });
  }

  Future<void> updateTitle(String title) async {
    if (!Platform.isMacOS) return;
    await _tray.setTitle(title);
  }

  Future<void> dispose() async {
    if (!Platform.isMacOS) return;
    await _tray.destroy();
  }
}
