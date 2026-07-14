// Sub-Admin Preset Template Setup Screen
// Delegates to the shared BusConfigSetupScreen with admin-level apiPrefix.
import 'package:flutter/material.dart';
import 'package:trace_odd/shared/widgets/layout_designer/bus_config_setup_screen.dart';

class SubAdminPresetSetupScreen extends StatelessWidget {
  final String apiPrefix;
  const SubAdminPresetSetupScreen({super.key, this.apiPrefix = '/admin'});

  @override
  Widget build(BuildContext context) {
    return BusConfigSetupScreen(
      companyId: '',
      companyName: 'Template',
      apiPrefix: apiPrefix,
    );
  }
}
