import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/data/audio.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/audio_page_header.dart';
import '../../common/view/audio_page_header_html_description.dart';
import '../../common/view/avatar_play_button.dart';
import '../../common/view/explore_online_popup.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/search_button.dart';
import '../../common/view/sliver_audio_page_control_panel.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import '../../settings/settings_model.dart';
import '../podcast_model.dart';
import 'podcast_sub_button.dart';
import 'sliver_podcast_page_list.dart';

class PodcastPage extends StatelessWidget with WatchItMixin {
  const PodcastPage({
    super.key,
    this.imageUrl,
    required this.pageId,
    this.audios,
    required this.title,
  });

  final String? imageUrl;
  final String pageId;
  final String title;
  final List<Audio>? audios;

  @override
  Widget build(BuildContext context) {
    watchPropertyValue((PlayerModel m) => m.lastPositions?.length);
    watchPropertyValue((LibraryModel m) => m.downloadsLength);

    watchPropertyValue((LibraryModel m) => m.showPodcastAscending(pageId));

    final libraryModel = di<LibraryModel>();
    final audiosWithDownloads = audios
            ?.map((e) => e.copyWith(path: libraryModel.getDownload(e.url)))
            .toList() ??
        [];

    return Scaffold(
      resizeToAvoidBottomInset: isMobile ? false : null,
      appBar: HeaderBar(
        adaptive: true,
        title: isMobile ? null : Text(title),
        actions: [
          Padding(
            padding: appBarSingleActionSpacing,
            child: SearchButton(
              onPressed: () {
                di<LibraryModel>().pushNamed(pageId: kSearchPageId);
                di<SearchModel>()
                  ..setAudioType(AudioType.podcast)
                  ..setSearchType(SearchType.podcastTitle);
              },
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: getAdaptiveHorizontalPadding(
                  constraints: constraints,
                  min: 40,
                ),
                sliver: SliverToBoxAdapter(
                  child: AudioPageHeader(
                    image: imageUrl == null
                        ? null
                        : _PodcastPageImage(imageUrl: imageUrl),
                    label: audios
                            ?.firstWhereOrNull((e) => e.genre != null)
                            ?.genre ??
                        context.l10n.podcast,
                    subTitle: audios?.firstOrNull?.artist,
                    description: AudioPageHeaderHtmlDescription(
                      description: audios?.firstOrNull?.albumArtist,
                      title: title,
                    ),
                    title: title,
                    onLabelTab: (text) => _onGenreTap(
                      context: context,
                      text: text,
                    ),
                    onSubTitleTab: (text) => _onArtistTap(
                      context: context,
                      text: text,
                    ),
                  ),
                ),
              ),
              SliverAudioPageControlPanel(
                controlPanel: _PodcastPageControlPanel(
                  audios: audiosWithDownloads,
                  pageId: pageId,
                  title: title,
                ),
              ),
              SliverPadding(
                padding: getAdaptiveHorizontalPadding(constraints: constraints),
                sliver: SliverPodcastPageList(
                  audios: audiosWithDownloads,
                  pageId: pageId,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _onArtistTap({
    required BuildContext context,
    required String text,
  }) async {
    await di<PodcastModel>().init(updateMessage: context.l10n.updateAvailable);
    di<LibraryModel>().pushNamed(pageId: kSearchPageId);
    di<SearchModel>()
      ..setAudioType(AudioType.podcast)
      ..setSearchQuery(text)
      ..search();
  }

  Future<void> _onGenreTap({
    required BuildContext context,
    required String text,
  }) async {
    await di<PodcastModel>().init(updateMessage: context.l10n.updateAvailable);
    final genres =
        di<SearchModel>().getPodcastGenres(di<SettingsModel>().usePodcastIndex);

    final genreOrNull = genres.firstWhereOrNull(
      (e) =>
          e.localize(context.l10n).toLowerCase() == text.toLowerCase() ||
          e.id.toLowerCase() == text.toLowerCase() ||
          e.name.toLowerCase() == text.toLowerCase(),
    );
    di<LibraryModel>().pushNamed(pageId: kSearchPageId);
    if (genreOrNull != null) {
      di<SearchModel>()
        ..setAudioType(AudioType.podcast)
        ..setPodcastGenre(genreOrNull)
        ..search();
    } else {
      if (context.mounted) {
        _onArtistTap(context: context, text: text);
      }
    }
  }
}

class _PodcastPageImage extends StatelessWidget {
  const _PodcastPageImage({
    required this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    var safeNetworkImage = SafeNetworkImage(
      fallBackIcon: Icon(
        Iconz().podcast,
        size: 80,
        color: theme.hintColor,
      ),
      errorIcon: Icon(
        Iconz().podcast,
        size: 80,
        color: theme.hintColor,
      ),
      url: imageUrl,
      fit: BoxFit.fitHeight,
      filterQuality: FilterQuality.medium,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      child: safeNetworkImage,
      onTap: () => showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: safeNetworkImage,
            ),
          ],
        ),
      ),
    );
  }
}

class _PodcastPageControlPanel extends StatelessWidget with WatchItMixin {
  const _PodcastPageControlPanel({
    required this.audios,
    required this.pageId,
    required this.title,
  });

  final List<Audio> audios;
  final String pageId;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PodcastReplayButton(audios: audios),
        PodcastSubButton(audios: audios, pageId: pageId),
        AvatarPlayButton(audios: audios, pageId: pageId),
        PodcastReorderButton(feedUrl: pageId),
        ExploreOnlinePopup(text: title),
      ],
    );
  }
}

class PodcastReplayButton extends StatelessWidget {
  const PodcastReplayButton({super.key, required this.audios});

  final List<Audio> audios;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.l10n.replayAllEpisodes,
      onPressed: () => di<PlayerModel>().removeLastPositions(audios),
      icon: Icon(Iconz().refresh),
    );
  }
}

class PodcastReorderButton extends StatelessWidget with WatchItMixin {
  const PodcastReorderButton({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    final ascending =
        watchPropertyValue((LibraryModel m) => m.showPodcastAscending(feedUrl));

    return IconButton(
      isSelected: ascending,
      tooltip: context.l10n.reorder,
      onPressed: () => di<LibraryModel>()
          .reorderPodcast(feedUrl: feedUrl, ascending: !ascending),
      icon: Icon(Iconz().reorder),
      selectedIcon: Icon(
        Iconz().reorder,
        color: context.t.colorScheme.primary,
      ),
    );
  }
}
