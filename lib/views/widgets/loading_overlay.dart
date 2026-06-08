import 'package:flutter/material.dart';
import 'package:gestion_commerce/config/theme.dart';

class LoadingOverlay extends StatelessWidget {
  final bool   isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Actual screen content ──────────────────────────────
        child,

        // ── Overlay (only when loading) ────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: isLoading
              ? _Overlay(message: message, key: const ValueKey('overlay'))
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ],
    );
  }
}

// ── Private overlay widget ─────────────────────────────────────────
class _Overlay extends StatelessWidget {
  final String? message;
  const _Overlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IgnorePointer(
      ignoring: false, // blocks all taps while loading
      child: Container(
        color: isDark
            ? Colors.black.withOpacity(0.55)
            : Colors.black.withOpacity(0.35),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E30) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Spinner ──────────────────────────────────────
                SizedBox(
                  width:  48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primary,
                    ),
                  ),
                ),

                // ── Message ───────────────────────────────────────
                if (message != null) ...[
                  const SizedBox(height: 18),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFFBBBBDD)
                          : const Color(0xFF4A4A6A),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Inline shimmer loader — for list items ─────────────────────────
class ShimmerLoader extends StatefulWidget {
  final int   itemCount;
  final double itemHeight;

  const ShimmerLoader({
    super.key,
    this.itemCount  = 6,
    this.itemHeight = 80,
  });

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>    _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      physics:     const NeverScrollableScrollPhysics(),
      shrinkWrap:  true,
      itemCount:   widget.itemCount,
      itemBuilder: (_, index) {
        return AnimatedBuilder(
          animation: _anim,
          builder: (_, __) {
            return Container(
              height: widget.itemHeight,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment(_anim.value - 1, 0),
                  end:   Alignment(_anim.value + 1, 0),
                  colors: isDark
                      ? [
                          const Color(0xFF1E1E30),
                          const Color(0xFF2A2A42),
                          const Color(0xFF1E1E30),
                        ]
                      : [
                          const Color(0xFFEEEEF8),
                          const Color(0xFFF8F8FF),
                          const Color(0xFFEEEEF8),
                        ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}