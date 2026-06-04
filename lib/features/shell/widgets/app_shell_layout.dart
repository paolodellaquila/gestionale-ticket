import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import 'app_header.dart';
import 'app_navigation.dart';

class AppShellLayout extends StatefulWidget {
  const AppShellLayout({super.key, required this.child});

  final Widget child;

  @override
  State<AppShellLayout> createState() => _AppShellLayoutState();
}

class _AppShellLayoutState extends State<AppShellLayout> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final path = GoRouterState.of(context).uri.path;
    final navIndex = navIndexForPath(path);

    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.surface,
        appBar: AppHeader(
          onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        drawer: AppNavigationDrawer(selectedIndex: navIndex),
        body: widget.child,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const AppHeader(),
      body: Row(
        children: [
          AppNavigationRail(selectedIndex: navIndex),
          const VerticalDivider(width: 1),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
