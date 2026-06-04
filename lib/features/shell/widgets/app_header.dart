import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_format.dart';
import '../../auth/viewmodels/auth_view_model.dart';
import '../../tickets/viewmodels/tickets_list_view_model.dart';
import 'app_navigation.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.onMenuTap,
    this.showSearch = true,
  });

  final VoidCallback? onMenuTap;
  final bool showSearch;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final counts = context.watch<TicketsListViewModel>().counts;
    final user = context.watch<AuthViewModel>().currentUser;
    final isMobile = context.isMobile;
    final path = GoRouterState.of(context).uri.path;
    final canAdd = path.startsWith('/tickets') && !path.contains('/nuovo');

    return AppBar(
      leading: isMobile && onMenuTap != null
          ? IconButton(icon: const Icon(Icons.menu), onPressed: onMenuTap)
          : null,
      title: isMobile ? const SiemBrand(compact: true) : _titleForPath(path),
      actions: [
        if (!isMobile)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                formatFullDate(DateTime.now()),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        IconButton(
          tooltip: 'Dashboard',
          icon: Badge(
            label: Text('${counts?.dashboard ?? 0}'),
            child: const Icon(Icons.dashboard_outlined),
          ),
          onPressed: () {},
        ),
        if (canAdd)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: FilledButton.icon(
              onPressed: () => context.go('/tickets/nuovo'),
              icon: const Icon(Icons.add, size: 18),
              label: isMobile ? const SizedBox.shrink() : const Text('Nuovo ticket'),
            ),
          ),
        PopupMenuButton<String>(
          offset: const Offset(0, 48),
          onSelected: (value) async {
            if (value == 'logout') {
              await context.read<AuthViewModel>().logout();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    user?.initials ?? '?',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user?.username ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        user?.roleLabel ?? '',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ],
            ),
          ),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'password', child: Text('Cambia password')),
            PopupMenuItem(value: 'logout', child: Text('Logout')),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _titleForPath(String path) {
    final title = switch (path) {
      '/tickets/mappa' => 'Mappa interventi',
      '/tickets/gestione' => 'Gestione ticket',
      '/tickets/nuovo' => 'Nuovo ticket',
      _ when path.contains(RegExp(r'^/tickets/\d')) => 'Dettaglio ticket',
      _ => 'Centro ticket',
    };
    return Text(title);
  }
}

