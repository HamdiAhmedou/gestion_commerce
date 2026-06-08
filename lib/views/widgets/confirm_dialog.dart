import 'package:flutter/material.dart';
import 'package:gestion_commerce/config/theme.dart';

class ConfirmDialog extends StatelessWidget {
  final String  title;
  final String  message;
  final String  confirmText;
  final String  cancelText;
  final Color?  confirmColor;
  final IconData? icon;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText  = 'Confirmer',
    this.cancelText   = 'Annuler',
    this.confirmColor,
    this.icon,
  });

  /// Static helper — call from anywhere:
  /// final confirmed = await ConfirmDialog.show(context, title: '...', message: '...');
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String  confirmText  = 'Confirmer',
    String  cancelText   = 'Annuler',
    Color?  confirmColor,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmDialog(
        title:        title,
        message:      message,
        confirmText:  confirmText,
        cancelText:   cancelText,
        confirmColor: confirmColor,
        icon:         icon,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final isDark     = theme.brightness == Brightness.dark;
    final dangerous  = confirmColor ?? AppTheme.error;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF1E1E30) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // ── Icon ──────────────────────────────────────────────
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: dangerous.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.delete_outline_rounded,
                color: dangerous,
                size: 32,
              ),
            ),

            const SizedBox(height: 20),

            // ── Title ─────────────────────────────────────────────
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            // ── Message ───────────────────────────────────────────
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? const Color(0xFF9E9EBF)
                    : const Color(0xFF6E6E8F),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            // ── Buttons ───────────────────────────────────────────
            Row(
              children: [
                // Cancel
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark
                          ? Colors.white70
                          : const Color(0xFF6E6E8F),
                      side: BorderSide(
                        color: isDark
                            ? const Color(0xFF3A3A55)
                            : const Color(0xFFE0E0EF),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      cancelText,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Confirm
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dangerous,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}