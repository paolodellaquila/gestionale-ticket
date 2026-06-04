import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/responsive/breakpoints.dart';
import '../../../core/router/navigator_keys.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/viewmodels/auth_view_model.dart';
import '../viewmodels/ticket_chat_view_model.dart';
import 'ticket_chat_panel.dart';

/// Monta FAB + pannello nell'overlay del navigator root (sopra tutte le route).
class TicketChatOverlay extends StatefulWidget {
  const TicketChatOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<TicketChatOverlay> createState() => _TicketChatOverlayState();
}

class _TicketChatOverlayState extends State<TicketChatOverlay> {
  OverlayEntry? _entry;
  AuthViewModel? _auth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthViewModel>();
    if (_auth != auth) {
      _auth?.removeListener(_syncOverlay);
      _auth = auth;
      _auth!.addListener(_syncOverlay);
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncOverlay());
    }
  }

  void _syncOverlay() {
    if (!mounted) return;
    final authenticated = context.read<AuthViewModel>().isAuthenticated;
    if (!authenticated) {
      _removeOverlay();
      return;
    }
    _mountOverlay();
  }

  void _mountOverlay() {
    if (_entry != null) return;

    final overlay = rootNavigatorKey.currentState?.overlay;
    if (overlay == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _mountOverlay());
      return;
    }

    _entry = OverlayEntry(
      builder: (overlayContext) {
        final vm = Provider.of<TicketChatViewModel>(overlayContext, listen: true);
        return _ChatLayer(vm: vm, mediaQuery: MediaQuery.of(overlayContext));
      },
    );
    overlay.insert(_entry!);
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _auth?.removeListener(_syncOverlay);
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _ChatLayer extends StatelessWidget {
  const _ChatLayer({required this.vm, required this.mediaQuery});

  final TicketChatViewModel vm;
  final MediaQueryData mediaQuery;

  @override
  Widget build(BuildContext context) {
    final isMobile = mediaQuery.size.width < Breakpoints.mobile;
    final bottom = isMobile ? 16.0 : 24.0;
    final right = isMobile ? 16.0 : 24.0;
    final panelWidth = isMobile
        ? (mediaQuery.size.width - right - 16).clamp(280.0, 420.0)
        : 400.0;

    return MediaQuery(
      data: mediaQuery,
      child: Positioned(
        right: right,
        bottom: bottom,
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (vm.isOpen) ...[
                TicketChatPanel(
                  width: panelWidth,
                  onClose: vm.close,
                ),
                const SizedBox(height: 12),
              ],
              FloatingActionButton.extended(
                heroTag: 'ticket_chat_fab',
                onPressed: vm.toggleOpen,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                icon: Icon(vm.isOpen ? Icons.close : Icons.chat_outlined),
                label: Text(vm.isOpen ? 'Chiudi' : 'Assistente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
