import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'firm_vitrins_tab.dart';
import 'firm_campaigns_tab.dart';

class FirmMarketingTab extends StatefulWidget {
  const FirmMarketingTab({super.key});

  @override
  State<FirmMarketingTab> createState() => _FirmMarketingTabState();
}

class _FirmMarketingTabState extends State<FirmMarketingTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryBlue,
            tabs: const [
              Tab(text: 'Vitrin Paketleri'),
              Tab(text: 'Kampanyalar'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              FirmVitrinsTab(),
              FirmCampaignsTab(),
            ],
          ),
        ),
      ],
    );
  }
}
