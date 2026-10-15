import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LegalDocumentView extends StatefulWidget {
  const LegalDocumentView({super.key, required this.assetPath});

  final String assetPath;

  @override
  State<LegalDocumentView> createState() => _LegalDocumentViewState();
}

class _LegalDocumentViewState extends State<LegalDocumentView> {
  late final Future<_LegalDocument> documentFuture = rootBundle.loadString(widget.assetPath).then(_LegalDocument.parse);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<_LegalDocument>(
      future: documentFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: BodyText(value: l10n.legalLoadError, color: Colors.black54),
          );
        }

        final document = snapshot.data;
        if (document == null) {
          return const Center(child: CustomCircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (document.title.isNotEmpty)
                CustomHeaderWidget(
                  title: document.title,
                  body: document.subtitle.isEmpty ? null : document.subtitle,
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final section in document.sections) ...[
                      _SectionCard(section: section),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final _Section section;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleText(value: section.title),
            for (final block in section.blocks) ...[
              const SizedBox(height: 10),
              _buildBlock(block),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBlock(_Block block) {
    return switch (block) {
      _Paragraph(:final text) => _buildParagraph(text),
      _SubHeading(:final text) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: BodyText(value: text, isBold: true, color: Colors.deepOrange),
      ),
      _Bullets(:final items) => Column(
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Icon(Icons.circle, size: 6, color: Colors.black54),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _RichBody(item)),
                ],
              ),
            ),
        ],
      ),
      _Numbered(:final items) => Column(
        children: [
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 24, child: BodyText(value: "${i + 1}.", color: Colors.black54)),
                  Expanded(child: _RichBody(items[i])),
                ],
              ),
            ),
        ],
      ),
      _TableBlock(:final rows) => _buildTable(rows),
    };
  }

  // Fully bold sentences (e.g. the emergency disclaimer) become a highlighted callout.
  Widget _buildParagraph(String text) {
    final isCallout = RegExp(r'^\*\*[^*]+\.\*\*$').hasMatch(text);
    if (!isCallout) return _RichBody(text);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lighterDeepOrange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 20, color: Colors.deepOrange),
          const SizedBox(width: 10),
          Expanded(child: _RichBody(text)),
        ],
      ),
    );
  }

  Widget _buildTable(List<List<String>> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final columnCount = rows.first.length;

    return Table(
      border: TableBorder.all(color: Colors.black12, borderRadius: BorderRadius.circular(8)),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        for (var r = 0; r < rows.length; r++)
          TableRow(
            decoration: r == 0 ? const BoxDecoration(color: AppColors.lighterDeepOrange) : null,
            children: [
              for (var c = 0; c < columnCount; c++)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: _RichBody(
                    c < rows[r].length ? rows[r][c] : "",
                    small: true,
                    isBold: r == 0,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// Body text that understands **bold** segments (BodyText can't do inline bold).
class _RichBody extends StatelessWidget {
  const _RichBody(this.text, {this.small = false, this.isBold = false});

  final String text;
  final bool small;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final base = small ? textTheme.bodySmall : textTheme.bodyMedium;

    final spans = <InlineSpan>[];
    var last = 0;
    for (final match in RegExp(r'\*\*(.+?)\*\*').allMatches(text)) {
      if (match.start > last) {
        spans.add(TextSpan(text: text.substring(last, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      last = match.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last)));
    }

    return Text.rich(
      TextSpan(
        style: base?.copyWith(
          color: Colors.black,
          fontWeight: isBold ? FontWeight.bold : null,
        ),
        children: spans,
      ),
    );
  }
}

// ---- Minimal parser for the markdown subset used in the two policy files ----

sealed class _Block {}

class _Paragraph extends _Block {
  _Paragraph(this.text);
  final String text;
}

class _SubHeading extends _Block {
  _SubHeading(this.text);
  final String text;
}

class _Bullets extends _Block {
  final List<String> items = [];
}

class _Numbered extends _Block {
  final List<String> items = [];
}

class _TableBlock extends _Block {
  _TableBlock(this.rows);
  final List<List<String>> rows;
}

class _Section {
  _Section(this.title);
  final String title;
  final List<_Block> blocks = [];
}

class _LegalDocument {
  _LegalDocument({required this.title, required this.subtitle, required this.sections});

  final String title;
  final String subtitle;
  final List<_Section> sections;

  static _LegalDocument parse(String raw) {
    final lines = raw.replaceAll('\r\n', '\n').split('\n');
    final headingPattern = RegExp(r'^#{1,6}\s+(.*)$');
    final subHeadingPattern = RegExp(r'^\d+\.\d+');
    final numberedPattern = RegExp(r'^\d+\.\s+(.*)$');
    final separatorCell = RegExp(r'^:?-+:?$');

    final intro = <String>[];
    final sections = <_Section>[];
    var skippedTitle = false;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty || line == '---') continue;

      final heading = headingPattern.firstMatch(line);
      if (heading != null) {
        final text = heading.group(1)!.trim();
        if (!skippedTitle) {
          skippedTitle = true; // first heading is the document title (already in the app bar)
          continue;
        }
        if (subHeadingPattern.hasMatch(text) && sections.isNotEmpty) {
          sections.last.blocks.add(_SubHeading(text));
        } else {
          sections.add(_Section(text));
        }
        continue;
      }

      if (sections.isEmpty) {
        intro.add(line.replaceAll('**', ''));
        continue;
      }
      final blocks = sections.last.blocks;

      if (line.startsWith('|')) {
        final rows = <List<String>>[];
        while (i < lines.length && lines[i].trim().startsWith('|')) {
          final cells = lines[i].trim().split('|').map((c) => c.trim()).toList();
          final inner = cells.sublist(1, cells.length - 1);
          if (!inner.every(separatorCell.hasMatch)) rows.add(inner);
          i++;
        }
        i--; // the for loop will increment again
        blocks.add(_TableBlock(rows));
        continue;
      }

      if (line.startsWith('* ') || line.startsWith('- ')) {
        final text = line.substring(2).trim();
        if (blocks.isNotEmpty && blocks.last is _Bullets) {
          (blocks.last as _Bullets).items.add(text);
        } else {
          blocks.add(_Bullets()..items.add(text));
        }
        continue;
      }

      final numbered = numberedPattern.firstMatch(line);
      if (numbered != null) {
        final text = numbered.group(1)!.trim();
        if (blocks.isNotEmpty && blocks.last is _Numbered) {
          (blocks.last as _Numbered).items.add(text);
        } else {
          blocks.add(_Numbered()..items.add(text));
        }
        continue;
      }

      blocks.add(_Paragraph(line));
    }

    return _LegalDocument(
      title: intro.isEmpty ? '' : intro.first,
      subtitle: intro.skip(1).join('\n'),
      sections: sections,
    );
  }
}