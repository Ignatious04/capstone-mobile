import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/schedule_provider.dart';
import 'package:capstone/core/shared/providers/team_provider.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/core/utilities/duty_resolver.dart';
import 'package:capstone/core/utilities/schedule_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ResponderScheduleScreen extends ConsumerWidget {
  const ResponderScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final duty = ref.watch(myDutyProvider);
    final now = ref.watch(phClockProvider).value ?? phNow();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: CustomHeaderWidget(title: l10n.schedule, body: l10n.scheduleSubtitle),
            ),
            Expanded(
              child: duty.when(
                data: (entries) => _ScheduleBody(entries: entries, now: now),
                loading: () => const Center(child: CustomCircularProgressIndicator()),
                error: (_, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: TitleText(value: l10n.scheduleLoadError),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleBody extends ConsumerWidget {
  const _ScheduleBody({required this.entries, required this.now});

  final List<DutyEntry> entries;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    final uid = ref.watch(authStateProvider).value?.uid ?? '';
    final teamNames = {for (final t in ref.watch(teamsForMemberProvider(uid)).value ?? const []) t.id: t.teamName};

    final upcoming = entries.where((e) => e.end.isAfter(now)).toList();
    final working = upcoming.where((e) => e.isWorking);
    final current = working.where((e) => !e.start.isAfter(now)).firstOrNull;
    final next = working.where((e) => e.start.isAfter(now)).firstOrNull;

    final today = DateTime.utc(now.year, now.month, now.day);
    final byDay = <DateTime, List<DutyEntry>>{};
    for (final e in upcoming) {
      (byDay[DateTime.utc(e.start.year, e.start.month, e.start.day)] ??= []).add(e);
    }

    String dayLabel(DateTime day) {
      final base = DateFormat('EEE, MMM d', locale).format(day);
      if (day == today) return '${l10n.scheduleToday} · $base';
      if (day == today.add(const Duration(days: 1))) return '${l10n.scheduleTomorrow} · $base';
      return base;
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _StatusCard(current: current, next: next, locale: locale),
        const SizedBox(height: 20),
        SectionTitle(icon: Icons.calendar_month, title: l10n.upcomingShifts),
        const SizedBox(height: 10),
        if (upcoming.isEmpty)
          BodyText(value: l10n.noUpcomingShifts(kScheduleWindowDays), color: AppColors.blackTextMuted)
        else
          for (final day in byDay.entries) ...[
            LabelText(value: dayLabel(day.key).toUpperCase(), color: AppColors.blackTextMuted),
            const SizedBox(height: 6),
            for (final e in day.value) _DutyCard(entry: e, teamName: teamNames[e.teamID]),
            const SizedBox(height: 6),
          ],
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.current, required this.next, required this.locale});

  final DutyEntry? current;
  final DutyEntry? next;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = current;
    final n = next;
    final onDuty = c != null;

    String when(DateTime t) => DateFormat('EEE, MMM d · HH:mm', locale).format(t);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: onDuty ? AppColors.lighterGreen : AppColors.bgWhiteLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.lighterBlack),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              onDuty ? Icons.shield : Icons.bedtime_outlined,
              size: 40,
              color: onDuty ? Colors.green : AppColors.blackTextMuted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleText(value: onDuty ? l10n.onDutyNow : l10n.offDuty, isBold: true),
                  BodyText(
                    value: c != null
                        ? l10n.onDutyUntil(when(c.end))
                        : n != null
                            ? l10n.nextShiftAt(when(n.start))
                            : l10n.noUpcomingShifts(kScheduleWindowDays),
                    color: AppColors.blackTextMuted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DutyCard extends StatelessWidget {
  const _DutyCard({required this.entry, required this.teamName});

  final DutyEntry entry;
  final String? teamName;

  static String _duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final clock = DateFormat('HH:mm');
    final crossesDay = entry.end.day != entry.start.day;

    final (String? label, Color bg, Color fg, IconData icon) = switch (entry.status) {
      DutyStatus.scheduled => (null, AppColors.lighterGreen, Colors.green, Icons.schedule),
      DutyStatus.extra => (
          entry.swapWithOwnerID.isNotEmpty ? l10n.dutySwapCover : l10n.dutyExtra,
          Colors.blue.shade50,
          Colors.blue,
          Icons.add_alarm,
        ),
      DutyStatus.overtime => (l10n.dutyOvertime, Colors.orange.shade50, Colors.orange, Icons.more_time),
      DutyStatus.onLeave => (l10n.dutyOnLeave, Colors.grey.shade200, Colors.grey, Icons.event_busy),
      DutyStatus.swappedAway => (l10n.dutySwappedAway, Colors.grey.shade200, Colors.grey, Icons.swap_horiz),
    };

    final range = '${clock.format(entry.start)} – ${clock.format(entry.end)}'
        '${crossesDay ? ' (${l10n.scheduleNextDay})' : ''}';

    return Opacity(
      opacity: entry.isWorking ? 1 : 0.6,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 10),
        color: AppColors.bgWhiteLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.lighterBlack),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, size: 28, color: fg),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodyText(value: range, isBold: true),
                        BodyText(
                          value: '${_duration(entry.end.difference(entry.start))} · ${teamName ?? l10n.personalShift}',
                          color: AppColors.blackTextMuted,
                        ),
                      ],
                    ),
                  ),
                  if (label != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                      child: LabelText(value: label, color: fg),
                    ),
                ],
              ),
              if (entry.note.isNotEmpty) ...[
                const SizedBox(height: 8),
                BodyText(value: entry.note, color: AppColors.blackTextMuted),
              ],
            ],
          ),
        ),
      ),
    );
  }
}