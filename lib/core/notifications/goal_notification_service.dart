import 'package:driver_finance/core/notifications/notification_service.dart';

class GoalNotificationService {
  static const int _notifId = 1;

  static Future<void> notifyGoalReached() async {
    await NotificationService.instance.showNotification(
      id: _notifId,
      title: 'Meta mensal atingida!',
      body: 'Parabéns! Você alcançou sua meta de receita este mês.',
    );
  }
}
