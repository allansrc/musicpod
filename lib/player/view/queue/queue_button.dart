import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../app/app_model.dart';
import '../../../app_config.dart';
import '../../../common/data/audio_type.dart';
import '../../../common/view/icons.dart';
import '../../../common/view/modals.dart';
import '../../../common/view/ui_constants.dart';
import '../../../extensions/build_context_x.dart';
import '../../../l10n/l10n.dart';
import '../../../radio/view/radio_history_list.dart';
import '../../player_model.dart';
import 'queue_body.dart';
import 'queue_dialog.dart';

class QueueButton extends StatelessWidget with WatchItMixin {
  const QueueButton({super.key, this.color, this.isSelected})
      : _mode = _QueueButtonMode.icon;

  const QueueButton.text({super.key, this.color, this.isSelected})
      : _mode = _QueueButtonMode.text;

  final Color? color;
  final bool? isSelected;

  final _QueueButtonMode _mode;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final playerToTheRight = context.mediaQuerySize.width > kSideBarThreshHold;
    final isFullScreen = watchPropertyValue((AppModel m) => m.fullWindowMode);
    final radio = watchPropertyValue(
      (PlayerModel m) => m.audio?.audioType == AudioType.radio,
    );

    final queueOrHistory = radio
        ? const SizedBox(
            width: 400,
            height: 500,
            child: RadioHistoryList(
              simpleList: true,
            ),
          )
        : QueueBody(
            selectedColor: theme.colorScheme.onSurface,
          );

    return switch (_mode) {
      _QueueButtonMode.icon => IconButton(
          isSelected: isSelected ??
              watchPropertyValue((AppModel m) => m.showQueueOverlay),
          color: color ?? theme.colorScheme.onSurface,
          padding: EdgeInsets.zero,
          tooltip: radio ? context.l10n.hearingHistory : context.l10n.queue,
          icon: Icon(
            Iconz.playlist,
            color: color ?? theme.colorScheme.onSurface,
          ),
          onPressed: () => onPressed(
            playerToTheRight: playerToTheRight,
            isFullScreen: isFullScreen,
            context: context,
            bottomSheetContent: queueOrHistory,
          ),
        ),
      _QueueButtonMode.text => TextButton(
          onPressed: () => onPressed(
            playerToTheRight: playerToTheRight,
            isFullScreen: isFullScreen,
            context: context,
            bottomSheetContent: queueOrHistory,
          ),
          child: Text(
            radio ? context.l10n.hearingHistory : context.l10n.queue,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
        )
    };
  }

  void onPressed({
    required bool playerToTheRight,
    required bool? isFullScreen,
    required BuildContext context,
    required Widget bottomSheetContent,
  }) {
    if ((playerToTheRight || isFullScreen == true) && !isMobilePlatform) {
      di<AppModel>().setOrToggleQueueOverlay();
    } else {
      showModal(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        content: ModalMode.platformModalMode == ModalMode.bottomSheet
            ? bottomSheetContent
            : const QueueDialog(),
        mode: ModalMode.platformModalMode,
      );
    }
  }
}

enum _QueueButtonMode {
  icon,
  text;
}
