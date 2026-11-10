import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/l10n/enum_labels.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/verification_provider.dart';
import 'package:capstone/core/shared/widgets/consent_banner.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/offline_sms_banner.dart';
import 'package:capstone/core/shared/widgets/reporting_restriction_banner.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/verification_banner.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/core/shared/models/report_model.dart';
import 'package:capstone/features/public_user/pre_call_guidance/utilities/offline_report_helper.dart';
import 'package:capstone/features/public_user/reporting/widgets/report_card.dart';
import 'package:capstone/core/shared/providers/report_repository_provider.dart';
import 'package:capstone/features/public_user/reporting/views/reports_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final ScrollController _scrollController = ScrollController();

  ReportStatusEnum? _statusFilter;
  ServiceTypeEnum? _typeFilter;

  void _clearFilters() => setState(() {
    _statusFilter = null;
    _typeFilter = null;
  });

  List<ReportModel> _applyFilters(List<ReportModel> reports) {
    return reports.where((r) {
      final matchesStatus = _statusFilter == null || r.status == _statusFilter;
      final matchesType = _typeFilter == null || r.incidentType == _typeFilter;
      return matchesStatus && matchesType;
    }).toList();
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: BodyText(
          value: label,
          isBold: true,
          color: selected ? AppColors.whiteTextFull : AppColors.blackTextFull,
        ),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.themeColor,
        checkmarkColor: AppColors.whiteTextFull,
      ),
    );
  }

  Widget _buildFilters(AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _filterChip(
                label: l10n.filterAll,
                selected: _statusFilter == null,
                onTap: () => setState(() => _statusFilter = null),
              ),
              for (final status in ReportStatusEnum.values)
                _filterChip(
                  label: status.label(l10n),
                  selected: _statusFilter == status,
                  onTap: () => setState(
                    () => _statusFilter = _statusFilter == status ? null : status,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _filterChip(
                label: l10n.filterAll,
                selected: _typeFilter == null,
                onTap: () => setState(() => _typeFilter = null),
              ),
              for (final type in ServiceTypeEnum.values)
                _filterChip(
                  label: type.label(l10n),
                  selected: _typeFilter == type,
                  onTap: () => setState(
                    () => _typeFilter = _typeFilter == type ? null : type,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Scrolls with the list instead of sitting above it, so they never push it down.
  static const _banners = Column(
    children: [
      ConsentBanner(),
      OfflineSmsBanner(),
      VerificationBanner(),
      ReportingRestrictionBanner(),
    ],
  );

  Color _getStatusColor(ReportModel report) {
    switch (report.status) {
      case ReportStatusEnum.pending:
        return AppColors.themeColor;
      case ReportStatusEnum.accepted:
        return Colors.blue;
      case ReportStatusEnum.dispatched:
        return Colors.purple;
      case ReportStatusEnum.onScene:
        return AppColors.darkerGreen;
      case ReportStatusEnum.resolved:
        return AppColors.blackTextMuted;
      default:
        return AppColors.blackTextFull;
    }
  }

  Color _getStatusBackgroundColor(ReportModel report) {
    switch (report.status) {
      case ReportStatusEnum.pending:
        return AppColors.lighterDeepOrange;
      case ReportStatusEnum.accepted:
        return AppColors.lighterBlue;
      case ReportStatusEnum.dispatched:
        return AppColors.lighterPurple;
      case ReportStatusEnum.onScene:
        return AppColors.lighterGreen;
      case ReportStatusEnum.resolved:
        return AppColors.lighterBlack;
      default:
        return AppColors.blackTextFull;
    }
  }

  Future<void> _refresh() async {
    final l10n = AppLocalizations.of(context)!;
    final userID = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (userID == null) return;

    try {
      await ref.read(reportRepositoryProvider).refreshReports(userID);
    } catch (_) {
      if (!mounted) return;
      CustomSnackbarHelper.show(context, text: l10n.refreshFailed);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final reports = ref.watch(reportsStreamProvider);
    final hasAnyReports = reports.value?.isNotEmpty ?? false;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: CustomHeaderWidget(title: l10n.reports, body: l10n.reportsSubtitle),
            ),
            if (hasAnyReports) _buildFilters(l10n),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: reports.when(
                  data: (allReports) {
                    if (allReports.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        children: [
                          _banners,
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.no_cell_outlined,
                                    size: 100,
                                    color: AppColors.blackTextMuted,
                                  ),
                                  const SizedBox(height: 10),
                                  BodyText(
                                    value: l10n.noReports,
                                    isBold: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    final reports = _applyFilters(allReports);
                    if (reports.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        children: [
                          _banners,
                          const SizedBox(height: 40),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.filter_list_off,
                                  size: 80,
                                  color: AppColors.blackTextMuted,
                                ),
                                const SizedBox(height: 10),
                                BodyText(value: l10n.noMatchingReports, isBold: true),
                                TextButton(
                                  onPressed: _clearFilters,
                                  child: Text(l10n.clearFilters),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: reports.length + 1, // +1 for the banners at the top
                      itemBuilder: (context, index) {
                        if (index == 0) return _banners;
                        final report = reports[index - 1];
                        return ReportCard(
                          referenceNumber: report.referenceNumber,
                          emergencyType: report.incidentType!.name,
                          createdAt: DateFormat(
                            "MMM dd, yyyy • h:mm a",
                            Localizations.localeOf(context).toString(),
                          ).format(report.createdAt!),
                          status: report.status!,
                          statusColor: _getStatusColor(report),
                          statusBackground: _getStatusBackgroundColor(report),
                          report: report,
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CustomCircularProgressIndicator(),
                  ),
                  error: (e, _) => Center(
                    child: Text(e.toString()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "reportsFAB",
        onPressed: () async {
          if (await handleOffline(context, ref)) return;
          if (!context.mounted) return;
          if (!await ensureCanReport(context, ref)) return;

          if (!context.mounted) return;

          final submitted = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const ReportsFormScreen(),
            ),
          );

          if (submitted == true && mounted) {
            _clearFilters();
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        },
        backgroundColor: AppColors.themeColor,
        foregroundColor: AppColors.whiteTextFull,
        child: Icon(Icons.add),
      ),
    );
  }
}
