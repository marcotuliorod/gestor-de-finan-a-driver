import 'package:driver_finance/core/notifications/notification_service.dart';
import 'package:driver_finance/features/maintenance/domain/entities/maintenance_record.dart';

class MaintenanceAlertScheduler {
  static const int _baseId = 10000;

  static Future<void> rescheduleAll(List<MaintenanceRecord> records) async {
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 7));

    for (final record in records) {
      final notifId = _idFor(record.id);
      final due = record.nextMaintenanceDate;

      if (due == null || due.isBefore(now) || due.isAfter(threshold)) {
        await NotificationService.instance.cancelNotification(notifId);
        continue;
      }

      final daysLeft = due.difference(now).inDays;
      final whenLabel = switch (daysLeft) {
        0 => 'hoje',
        1 => 'amanhã',
        _ => 'em $daysLeft dias',
      };

      await NotificationService.instance.showNotification(
        id: notifId,
        title: 'Manutenção próxima: ${record.type}',
        body: 'Revisão vence $whenLabel. Agende com antecedência.',
      );
    }
  }

  static int _idFor(String recordId) =>
      _baseId + (recordId.hashCode.abs() % 89999);
}
