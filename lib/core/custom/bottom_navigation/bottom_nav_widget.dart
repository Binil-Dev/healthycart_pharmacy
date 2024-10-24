import 'package:flutter/material.dart';
import 'package:healthycart_pharmacy/core/services/custom_upgrade_alert.dart';
import 'package:healthycart_pharmacy/features/general/presentation/provider/general_provider.dart';
import 'package:healthycart_pharmacy/utils/constants/colors/colors.dart';
import 'package:healthycart_pharmacy/utils/constants/image/icon.dart';
import 'package:provider/provider.dart';

class BottomNavigationWidget extends StatefulWidget {
  const BottomNavigationWidget({
    super.key,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.text4,
    required this.tabItems,
    required this.selectedImage1,
    required this.unselectedImage1,
    required this.selectedImage2,
    required this.unselectedImage2,
  });
  final String text1;
  final String text2;
  final String text3;
  final String text4;
  final Image selectedImage1;
  final Image unselectedImage1;
  final Image selectedImage2;
  final Image unselectedImage2;
  final List<Widget> tabItems;
  @override
  State<BottomNavigationWidget> createState() => _BottonNavTabState();
}

class _BottonNavTabState extends State<BottomNavigationWidget>
    with TickerProviderStateMixin {
  int selectedIndex = 0;
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabItems.length, vsync: this);
    _tabController.addListener(_handleTabSelecttion);
  }

  void _handleTabSelecttion() {
    if (_tabController.index == selectedIndex) return;
    setState(() {
      selectedIndex = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelecttion);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     return  CUpgradeAlert(
      minAppstoreVersion:
          context.read<GeneralProvider>().generalModel?.minAppstoreVersionPharmacy ?? '1.0.0',
      minPlaystoreVersion:
          context.read<GeneralProvider>().generalModel?.minPlaystoreVersionPharmacy ?? '1.0.0',
      child: DefaultTabController(
        length: widget.tabItems.length,
        child: Scaffold(
          body: TabBarView(
            controller: _tabController,
              clipBehavior: Clip.antiAlias,
              // physics: const NeverScrollableScrollPhysics(),
              children: widget.tabItems),
          bottomNavigationBar: PhysicalModel(
            color: Colors.white,
            elevation: 10,
            child: TabBar(
              controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: UnderlineTabIndicator(
                  borderSide:
                      BorderSide(color: BColors.mainlightColor, width: 8.0),
                  insets: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 66.0),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
                labelStyle: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(fontSize: 10, fontWeight: FontWeight.w600),
                labelColor: BColors.mainlightColor,
                unselectedLabelColor: BColors.black,
                onTap: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                tabs: [
                  Tab(
                    icon: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: selectedIndex == 0
                          ? widget.selectedImage1
                          : widget.unselectedImage1,
                    ),
                    text: widget.text1,
                  ),
                  Tab(
                    text: widget.text2,
                    icon: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: selectedIndex == 1
                          ? widget.selectedImage2
                          : widget.unselectedImage2,
                    ),
                  ),
                  Tab(
                    text: widget.text3,
                    icon: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: selectedIndex == 2
                          ? Image.asset(
                              BIcon.addBanner,
                              height: 29,
                              width: 29,
                            )
                          : Image.asset(
                              BIcon.addBannerBlack,
                              height: 25,
                              width: 25,
                            ),
                    ),
                  ),
                  Tab(
                    text: widget.text4,
                    icon: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: selectedIndex == 3
                          ? Image.asset(
                              BIcon.profile,
                              height: 28,
                              width: 28,
                            )
                          : Image.asset(
                              BIcon.profileBlack,
                              height: 24,
                              width: 24,
                            ),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
