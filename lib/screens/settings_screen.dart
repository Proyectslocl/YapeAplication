import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/payment_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final PaymentController controller;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionCard(
                title: 'Detección',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile.adaptive(
                      value: controller.detectionEnabled,
                      activeColor: const Color(0xFF7B2CBF),
                      title: const Text('Activar detección automática'),
                      subtitle: const Text('Lee notificaciones y registra pagos.'),
                      onChanged: controller.toggleDetection,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: controller.openNotificationSettings,
                      icon: const Icon(Icons.notifications_active_outlined),
                      label: const Text('Activar acceso a notificaciones'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Horario activo',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Hora de inicio'),
                      subtitle: Text(
                        timeFormat.format(_toDate(controller.startTime)),
                      ),
                      trailing: const Icon(Icons.schedule),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: controller.startTime,
                        );
                        if (time != null) {
                          controller.updateSchedule(
                            start: time,
                            end: controller.endTime,
                          );
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Hora de fin'),
                      subtitle: Text(
                        timeFormat.format(_toDate(controller.endTime)),
                      ),
                      trailing: const Icon(Icons.schedule),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: controller.endTime,
                        );
                        if (time != null) {
                          controller.updateSchedule(
                            start: controller.startTime,
                            end: time,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Solo se contarán pagos dentro de este horario.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Estado de permisos',
                child: Row(
                  children: [
                    Icon(
                      controller.notificationPermissionGranted
                          ? Icons.check_circle
                          : Icons.error_outline,
                      color: controller.notificationPermissionGranted
                          ? Colors.green
                          : Colors.redAccent,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        controller.notificationPermissionGranted
                            ? 'Acceso a notificaciones activo.'
                            : 'Acceso a notificaciones pendiente.',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  DateTime _toDate(TimeOfDay time) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
