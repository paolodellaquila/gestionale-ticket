import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class NavDestination {
  const NavDestination({
    required this.label,
    required this.icon,
    required this.route,
    this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String route;
}

const ticketNavDestinations = [
  NavDestination(
    label: 'Code',
    icon: Icons.inbox_outlined,
    selectedIcon: Icons.inbox,
    route: '/tickets',
  ),
  NavDestination(
    label: 'Mappa',
    icon: Icons.map_outlined,
    selectedIcon: Icons.map,
    route: '/tickets/mappa',
  ),
  NavDestination(
    label: 'Gestione',
    icon: Icons.manage_search_outlined,
    selectedIcon: Icons.manage_search,
    route: '/tickets/gestione',
  ),
  NavDestination(
    label: 'Nuovo',
    icon: Icons.add_circle_outline,
    selectedIcon: Icons.add_circle,
    route: '/tickets/nuovo',
  ),
];

int navIndexForPath(String path) {
  if (path.startsWith('/tickets/nuovo')) return 3;
  if (path.startsWith('/tickets/gestione')) return 2;
  if (path.startsWith('/tickets/mappa')) return 1;
  if (path.startsWith('/tickets')) return 0;
  return 0;
}

class AppNavigationRail extends StatelessWidget {
  const AppNavigationRail({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      extended: true,
      minExtendedWidth: 180,
      labelType: NavigationRailLabelType.none,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: const SiemBrand(compact: false),
      ),
      destinations: ticketNavDestinations
          .map(
            (d) => NavigationRailDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon ?? d.icon),
              label: Text(d.label),
            ),
          )
          .toList(),
      onDestinationSelected: (i) {
        context.go(ticketNavDestinations[i].route);
      },
    );
  }
}

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: SiemBrand(compact: false),
            ),
            const Divider(),
            ...ticketNavDestinations.asMap().entries.map((e) {
              final selected = e.key == selectedIndex;
              return ListTile(
                leading: Icon(
                  selected
                      ? (e.value.selectedIcon ?? e.value.icon)
                      : e.value.icon,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
                title: Text(
                  e.value.label,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                selected: selected,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.go(e.value.route);
                },
              );
            }),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text(
                'SIEM · Gestionale Ticket',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SiemBrand extends StatelessWidget {
  const SiemBrand({super.key, required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: const Text(
            'S',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SIEM Ticket',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Energy Management',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
