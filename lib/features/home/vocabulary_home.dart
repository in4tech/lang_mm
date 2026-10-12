import 'package:flutter/material.dart';
import 'package:lang/features/home/sample/home_sample.dart';
import 'package:lang/features/home/widgets/home_header.dart';
import 'package:lang/features/home/widgets/home_sidebar.dart';
import 'package:lang/features/home/widgets/recent_panel.dart';
import 'package:lang/features/home/widgets/statistics_panel.dart';
import 'package:lang/features/home/widgets/today_panel.dart';
import 'package:lang/theme/home_text.dart';
import 'package:lang/l10n/app_localizations.dart';

class VocabularyHome extends StatelessWidget {
  const VocabularyHome({super.key, this.sample = HomeSample.current});

  final HomeSample sample;

  static const designWidth = 1440.0;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : designWidth;
          return Scrollbar(
            child: SingleChildScrollView(
              child: SizedBox(
                width: width,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: designWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const HomeHeader(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HomeSidebar(sample: sample),
                            SizedBox(
                              width: designWidth - HomeSidebar.width,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  32,
                                  20,
                                  46,
                                  48,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      localizations.statisticsHeading,
                                      style: HomeText.title,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: StatisticsPanel(
                                            sample: sample,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        TodayPanel(sample: sample),
                                      ],
                                    ),
                                    const SizedBox(height: 28),
                                    RecentPanel(sample: sample),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
