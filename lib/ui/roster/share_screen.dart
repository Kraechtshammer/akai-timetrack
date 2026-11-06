// Share preview of the team plan (F11): the picture and a Share button.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../material.dart';

import '../../app/providers.dart';
import '../../core/time.dart';
import '../common.dart';
import 'plan_image.dart';

class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({super.key, required this.week});

  /// The Monday of the week.
  final DateTime week;

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  final _key = GlobalKey();
  var _busy = false;

  Future<void> _share() async {
    setState(() => _busy = true);
    try {
      final boundary =
          _key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(
        pixelRatio: TeamPlanImage.pixelRatio,
      );
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/team-plan-${dayKey(widget.week)}.png';
      await File(path).writeAsBytes(data!.buffer.asUint8List(), flush: true);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(path, mimeType: 'image/png')]),
      );
    } catch (e) {
      if (mounted) context.showSnack('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final week = ref.watch(rosterWeekProvider(widget.week));
    final starts = ref.settings.teamStarts;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.teamShareTitle)),
      body: week == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DecoratedBox(
                  // Keeps the white picture visible in dark mode.
                  decoration: BoxDecoration(
                    border: Border.all(color: context.colors.outlineVariant),
                    boxShadow: const [
                      BoxShadow(blurRadius: 8, color: Color(0x33000000)),
                    ],
                  ),
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    // Inside the FittedBox so the PNG is rendered at the
                    // full layout size, not the scaled-down one.
                    child: RepaintBoundary(
                      key: _key,
                      child: TeamPlanImage(
                        week: week,
                        starts: starts,
                        l10n: l10n,
                        restaurant: ref.settings.restaurant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.teamShareHint, style: context.text.bodyMedium),
                const SizedBox(height: 16),
                M3EButton.icon(
                  style: M3EButtonStyle.filled,
                  size: M3EButtonSize.md,
                  decoration: M3EButtonDecoration.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  onPressed: _busy ? null : _share,
                  icon: _busy
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.share),
                  label: Text(l10n.share),
                ),
              ],
            ),
    );
  }
}
