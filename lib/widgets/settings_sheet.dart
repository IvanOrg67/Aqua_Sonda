import 'package:flutter/material.dart';
import '../services/database_auth_service.dart';

Future<void> openSettingsSheet(BuildContext context, {String? correo}) async {
  showModalBottomSheet(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final color = Theme.of(ctx).colorScheme;
      final text = Theme.of(ctx).textTheme;

      // Intentar leer correo de argumentos si no se proporcionó
      String? correoArg = correo;
      if (correoArg == null) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        correoArg = args?['correo'] as String?;
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: color.primary),
                const SizedBox(width: 8),
                Text('Ajustes', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Divider(color: Theme.of(ctx).dividerColor),

            // Correo del usuario
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.alternate_email),
              title: const Text('Correo de la cuenta'),
              subtitle: Text(correoArg ?? '—'),
            ),

            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_reset),
              title: const Text('Cambiar contraseña'),
              subtitle: const Text('Te pediremos la contraseña actual'),
              onTap: () async {
                Navigator.of(ctx).pop();
                await showChangePasswordDialog(context, correo: correoArg);
              },
            ),

            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Cerrar sesión'),
              titleTextStyle: text.bodyLarge?.copyWith(color: Colors.redAccent, fontWeight: FontWeight.w700),
              onTap: () async {
                Navigator.of(ctx).pop();
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (dctx) => AlertDialog(
                    title: const Text('Cerrar sesión'),
                    content: const Text('¿Seguro que deseas cerrar sesión?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(dctx).pop(false), child: const Text('Cancelar')),
                      TextButton(onPressed: () => Navigator.of(dctx).pop(true), child: const Text('Cerrar')),
                    ],
                  ),
                );
                if (ok == true) {
                  try {
                    DatabaseAuthService().logout();
                    if (!context.mounted) return;
                    await Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showChangePasswordDialog(BuildContext context, {String? correo}) async {
  final formKey = GlobalKey<FormState>();
  final currentCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final repeatCtrl = TextEditingController();
  bool loading = false;

  await showDialog(
    context: context,
    barrierDismissible: !loading,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña actual'),
                validator: (v) => (v==null||v.isEmpty) ? 'Requerida' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: newCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nueva contraseña'),
                validator: (v) => (v==null||v.length<6) ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: repeatCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Repetir nueva contraseña'),
                validator: (v) => (v!=newCtrl.text) ? 'No coincide' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: loading ? null : () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: loading
                ? null
                : () async {
                    if (!formKey.currentState!.validate()) return;
                    setLocal(() { loading = true; });
                    
                    // TODO: Implement password change via Supabase
                    await Future.delayed(const Duration(milliseconds: 500));
                    
                    setLocal(() { loading = false; });
                    if (!ctx.mounted) return;
                    Navigator.of(ctx).pop();
                    
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cambio de contraseña aún no implementado')),
                    );
                  },
            child: loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Guardar'),
          ),
        ],
      ),
    ),
  );
}
