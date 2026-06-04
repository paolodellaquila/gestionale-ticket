import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _shellDuration = Duration(milliseconds: 320);
const _shellReverseDuration = Duration(milliseconds: 260);
const _detailDuration = Duration(milliseconds: 380);
const _detailReverseDuration = Duration(milliseconds: 300);

/// Transizione leggera per login e pagine pubbliche.
CustomTransitionPage<T> fadeTransitionPage<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
        child: child,
      );
    },
  );
}

/// Transizione per le pagine dentro la shell (Code, Gestione, Nuovo).
CustomTransitionPage<T> shellTransitionPage<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: _shellDuration,
    reverseTransitionDuration: _shellReverseDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final enter = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final exit = CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeInCubic,
        reverseCurve: Curves.easeOutCubic,
      );

      return FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(enter),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(enter),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.03, 0),
            ).animate(exit),
            child: child,
          ),
        ),
      );
    },
  );
}

/// Transizione per il dettaglio ticket (push a tutto schermo).
CustomTransitionPage<T> detailTransitionPage<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: _detailDuration,
    reverseTransitionDuration: _detailReverseDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final enter = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(enter),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.85, end: 1).animate(enter),
          child: child,
        ),
      );
    },
  );
}
