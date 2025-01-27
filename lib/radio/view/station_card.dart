import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/theme.dart';
import '../../library/library_model.dart';
import '../../common/view/audio_fall_back_icon.dart';
import 'station_page.dart';

class StationCard extends StatelessWidget {
  const StationCard({
    super.key,
    required this.station,
    required this.startPlaylist,
  });

  final Audio? station;
  final Future<void> Function({
    required List<Audio> audios,
    required String listName,
    int? index,
  }) startPlaylist;

  @override
  Widget build(BuildContext context) {
    return AudioCard(
      bottom: AudioCardBottom(text: station?.title?.replaceAll('_', '') ?? ''),
      onPlay: station?.uuid == null
          ? null
          : () => startPlaylist(
                audios: [station!],
                listName: station!.uuid!,
              ),
      onTap: station?.uuid == null
          ? null
          : () => di<LibraryModel>().push(
                builder: (_) => StationPage(station: station!),
                pageId: station!.uuid!,
              ),
      image: SizedBox.expand(
        child: SafeNetworkImage(
          fallBackIcon: AudioFallBackIcon(
            audio: station,
            iconSize: 70,
          ),
          errorIcon: AudioFallBackIcon(
            audio: station,
            iconSize: 70,
          ),
          url: station?.imageUrl,
          fit: BoxFit.scaleDown,
          height: audioCardDimension,
          width: audioCardDimension,
        ),
      ),
    );
  }
}
