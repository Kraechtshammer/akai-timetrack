/// In-app updates from GitHub releases: versions, the release data and the
/// release notes shown in the update popup. Pure logic; the network, files
/// and the installer are in `platform/app_update.dart`.
library;

/// A version like 1.0.2, from a tag ("v1.0.2") or Android's versionName.
class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.parts);

  final List<int> parts;

  /// Reads "1.0.2", "v1.0.2" or "1.0.2+3" (the build number is ignored).
  static AppVersion? tryParse(String text) {
    final match = RegExp(r'^v?(\d+(?:\.\d+)*)').firstMatch(text.trim());
    if (match == null) return null;
    return AppVersion(match.group(1)!.split('.').map(int.parse).toList());
  }

  @override
  int compareTo(AppVersion other) {
    for (var i = 0; i < parts.length || i < other.parts.length; i++) {
      final a = i < parts.length ? parts[i] : 0;
      final b = i < other.parts.length ? other.parts[i] : 0;
      if (a != b) return a.compareTo(b);
    }
    return 0;
  }

  bool operator >(AppVersion other) => compareTo(other) > 0;
  bool operator <=(AppVersion other) => compareTo(other) <= 0;

  @override
  bool operator ==(Object other) =>
      other is AppVersion && compareTo(other) == 0;

  @override
  int get hashCode => Object.hashAll(_trimmed);

  List<int> get _trimmed {
    var end = parts.length;
    while (end > 0 && parts[end - 1] == 0) {
      end--;
    }
    return parts.sublist(0, end);
  }

  @override
  String toString() => parts.join('.');
}

/// A published release with an APK.
class ReleaseInfo {
  const ReleaseInfo({
    required this.version,
    required this.notes,
    required this.apkUrl,
    required this.apkSize,
  });

  final AppVersion version;

  /// The release text (Markdown, from scripts/release-notes.sh).
  final String notes;
  final String apkUrl;

  /// In bytes, to check the download is complete.
  final int apkSize;

  /// From GitHub's `releases/latest` answer. Null for drafts, pre-releases,
  /// unreadable tags and releases without an APK.
  static ReleaseInfo? fromJson(Map<String, dynamic> json) {
    if (json['draft'] == true || json['prerelease'] == true) return null;
    final version = AppVersion.tryParse('${json['tag_name'] ?? ''}');
    final assets = json['assets'];
    if (version == null || assets is! List) return null;
    for (final asset in assets.whereType<Map<String, dynamic>>()) {
      final name = '${asset['name'] ?? ''}';
      final url = asset['browser_download_url'];
      final size = asset['size'];
      if (name.toLowerCase().endsWith('.apk') && url is String && size is int) {
        return ReleaseInfo(
          version: version,
          notes: '${json['body'] ?? ''}',
          apkUrl: url,
          apkSize: size,
        );
      }
    }
    return null;
  }
}

/// The kinds of release-note sections shown in the popup.
enum NotesKind { added, fixed, improved, other }

class NotesSection {
  const NotesSection(this.kind, this.items);

  final NotesKind kind;
  final List<String> items;
}

/// The parts of the release text meant for her: "New", "Fixed" and
/// "Improved". "Behind the scenes", "Other changes" and the commit link are
/// left out. A hand-written text without these headings is shown as it is,
/// as one [NotesKind.other] section.
List<NotesSection> userNotes(String markdown) {
  const kinds = {
    'new': NotesKind.added,
    'fixed': NotesKind.fixed,
    'improved': NotesKind.improved,
  };
  final lines = markdown.split(RegExp(r'\r?\n'));
  final hasHeadings = lines.any((l) => l.startsWith('#'));
  final sections = <NotesSection>[];
  NotesKind? current = hasHeadings ? null : NotesKind.other;
  var items = <String>[];

  void flush() {
    if (current != null && items.isNotEmpty) {
      sections.add(NotesSection(current, items));
    }
    items = [];
  }

  for (final raw in lines) {
    final line = raw.trim();
    if (line.startsWith('#')) {
      flush();
      final heading = line.replaceFirst(RegExp(r'^#+\s*'), '').toLowerCase();
      current = kinds[heading];
    } else if (line.isNotEmpty && current != null) {
      if (!hasHeadings || RegExp(r'^[-*]\s').hasMatch(line)) {
        items.add(_plain(line.replaceFirst(RegExp(r'^[-*]\s+'), '')));
      }
    }
  }
  flush();
  return sections;
}

/// Strips the Markdown the notes may contain: links, bold, code.
String _plain(String text) => text
    .replaceAllMapped(RegExp(r'\[([^\]]*)\]\([^)]*\)'), (m) => m.group(1)!)
    .replaceAll(RegExp(r'\*\*|__|`'), '');

/// The local file name of a downloaded update.
String apkFileName(AppVersion version) => 'timetrack-$version.apk';

/// Downloaded files that can go after an update: APKs of the installed
/// version or older (the update worked) and unfinished downloads. The APK of
/// a newer version stays, so "restart update" needn't download it again.
List<String> updateFilesToDelete(Iterable<String> names, AppVersion installed) {
  bool obsolete(String name) {
    if (name.endsWith('.part')) return true;
    final version = _apkVersion(name);
    return version != null && version <= installed;
  }

  return names.where(obsolete).toList();
}

AppVersion? _apkVersion(String name) {
  final match = RegExp(r'^timetrack-(.+)\.apk$').firstMatch(name);
  return match == null ? null : AppVersion.tryParse(match.group(1)!);
}

/// How often the app looks for an update on its own (on start and when it
/// comes back to the foreground).
const updateCheckInterval = Duration(hours: 6);

bool updateCheckDue(DateTime? lastCheck, DateTime now) =>
    lastCheck == null ||
    now.isBefore(lastCheck) || // the clock was changed
    now.difference(lastCheck) >= updateCheckInterval;
