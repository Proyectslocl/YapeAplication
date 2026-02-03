import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/payment_controller.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final PaymentController controller;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_PE', symbol: 'S/');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ganancias por Yape'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(controller: controller),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _TotalCard(
                  total: currencyFormat.format(controller.totalToday),
                ),
                const SizedBox(height: 16),
                _DetectionStatus(controller: controller),
                const SizedBox(height: 16),
                Text(
                  'Pagos recibidos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (controller.payments.isEmpty)
                  _EmptyState()
                else
                  ...controller.payments.map(
                    (payment) => _PaymentTile(
                      amount: currencyFormat.format(payment.amount),
                      sender: payment.senderName,
                      time: DateFormat('HH:mm').format(payment.timestamp),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total});

  final String total;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFF7B2CBF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total del día',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              total,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetectionStatus extends StatelessWidget {
  const _DetectionStatus({required this.controller});

  final PaymentController controller;

  @override
  Widget build(BuildContext context) {
    final isActive = controller.detectionEnabled;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Detección automática',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Switch(
                  value: isActive,
                  activeColor: const Color(0xFF7B2CBF),
                  onChanged: controller.toggleDetection,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isActive
                  ? 'La detección está activa.'
                  : 'La detección está desactivada.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Solo se contarán pagos dentro de este horario',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              controller.notificationPermissionGranted
                  ? 'Permisos de notificación concedidos.'
                  : 'Permisos pendientes. Actívalos desde ajustes.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.amount, required this.sender, required this.time});

  final String amount;
  final String? sender;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE0AAFF),
          child: Icon(Icons.payments, color: Color(0xFF5A189A)),
        ),
        title: Text(amount),
        subtitle: Text(sender ?? 'Remitente no identificado'),
        trailing: Text(time),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF7B2CBF)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Aún no se registran pagos en el horario configurado.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
