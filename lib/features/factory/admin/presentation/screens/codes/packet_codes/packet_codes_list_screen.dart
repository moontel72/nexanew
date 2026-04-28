import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/packet_codes/packet_codes_bloc.dart';
import 'package:nexatrace_system/shared/models/code/packet_code_model.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/cards/code_card.dart';
import 'package:nexatrace_system/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nexatrace_system/core/constants/api_endpoints.dart';

class PacketCodesListScreen extends StatefulWidget {
  const PacketCodesListScreen({super.key});

  @override
  State<PacketCodesListScreen> createState() => _PacketCodesListScreenState();
}

class _PacketCodesListScreenState extends State<PacketCodesListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PacketCodesBloc>().add(const LoadPacketCodes());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _goToGenerate() {
    context.go('/factory/codes/packet/generate');
  }

  void _showDetails(PacketCodeModel packet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Packet Details',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 12.h),
                _kv('Code', packet.code),
                _kv('Status', packet.status.name),
                _kv('Units', packet.unitCount.toString()),
                if (packet.packetType != null) _kv('Type', packet.packetType!),
                if (packet.dimensions != null)
                  _kv('Dimensions', packet.dimensions!),
                SizedBox(height: 16.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              k,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Packet Codes',
        showBackButton: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: PrimaryButton(
              onPressed: _goToGenerate,
              text: 'Generate',
              icon: Icons.add,
              backgroundColor: AppColors.secondary,
              textColor: Colors.white,
            ),
          ),
        ],
      ),
      body: BlocConsumer<PacketCodesBloc, PacketCodesState>(
        listener: (context, state) async {
          if (state.status == PacketCodesStatus.exported &&
              state.exportPath != null &&
              state.exportPath!.trim().isNotEmpty) {
            final raw = state.exportPath!.trim();
            final uri = Uri.tryParse(raw);
            final downloadUri = (uri != null && uri.hasScheme)
                ? uri
                : Uri.parse(ApiEndpoints.getFullUrl(raw.startsWith('/') ? raw : '/$raw'));

            await launchUrl(downloadUri, mode: LaunchMode.platformDefault);

            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Download started')),
            );
          }

          if (state.status == PacketCodesStatus.error &&
              state.errorMessage != null &&
              state.errorMessage!.trim().isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == PacketCodesStatus.loading ||
              state.status == PacketCodesStatus.generating) {
            return const Center(child: LoadingIndicator());
          }

          if (state.status == PacketCodesStatus.error) {
            return Center(
              child: EmptyState(
                title: 'Failed to load packet codes',
                description: state.errorMessage ?? 'Unknown error',
                icon: Icons.error_outline,
                iconColor: AppColors.error,
                actionButton: PrimaryButton(
                  text: 'Retry',
                  icon: Icons.refresh,
                  backgroundColor: AppColors.secondary,
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<PacketCodesBloc>().add(
                      const LoadPacketCodes(),
                    );
                  },
                ),
              ),
            );
          }

          final packets = state.filteredPacketCodes;
          if (packets.isEmpty) {
            return Center(
              child: EmptyState(
                title: 'No packet codes yet',
                description:
                    'Generate packet codes to start packaging workflows.',
                icon: Icons.inventory_2_outlined,
                iconColor: AppColors.secondary,
                actionButton: PrimaryButton(
                  text: 'Generate Packet Codes',
                  icon: Icons.add,
                  backgroundColor: AppColors.secondary,
                  textColor: Colors.white,
                  onPressed: _goToGenerate,
                ),
              ),
            );
          }

          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.all(16.w),
              itemCount: packets.length,
              separatorBuilder: (_, _) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final p = packets[index];
                return CodeCard(
                code: p.code,
                codeType: p.type.name,
                status: p.status.name,
                batchNumber: p.batchId,
                generatedDate: p.generatedAt,
                productName: '',
                actions: [
                  OutlinedButton.icon(
                    onPressed: () => _showDetails(p),
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('View Details'),
                  ),
                  OutlinedButton.icon(
                    onPressed: p.status == CodeStatus.published
                        ? () async {
                            final format = await showModalBottomSheet<String>(
                              context: context,
                              builder: (context) {
                                return SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.picture_as_pdf),
                                        title: const Text('Download PDF'),
                                        onTap: () => Navigator.pop(context, 'pdf'),
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.table_chart),
                                        title: const Text('Download CSV'),
                                        onTap: () => Navigator.pop(context, 'csv'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                            if (format == null) return;
                            context
                                .read<PacketCodesBloc>()
                                .add(ExportPacketCodes([p.id], format));
                          }
                        : null,
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Download'),
                  ),
                  OutlinedButton.icon(
                    onPressed: p.canPublish
                        ? () {
                            context
                                .read<PacketCodesBloc>()
                                .add(PublishPacketCode(p.id));
                          }
                        : null,
                    icon: const Icon(Icons.publish_outlined),
                    label: const Text('Publish'),
                  ),
                ],
                onTap: () => _showDetails(p),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
