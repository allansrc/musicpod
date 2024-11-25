import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../view/icons.dart';

enum AudioType {
  local,
  radio,
  podcast;

  String localize(AppLocalizations l10n) => switch (this) {
        local => l10n.localAudio,
        radio => l10n.radio,
        podcast => l10n.podcast,
      };

  IconData get iconData => switch (this) {
        local => Iconz.localAudio,
        radio => Iconz.radio,
        podcast => Iconz.podcast,
      };

  IconData get selectedIconData => switch (this) {
        local => Iconz.localAudioFilled,
        radio => Iconz.radioFilled,
        podcast => Iconz.podcastFilled,
      };
}