import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Servicio genérico para manejar el registro de eventos en Firebase Analytics.
class AnalyticsService {
  AnalyticsService._();

  /// Usamos un getter para evitar que se acceda a Firebase antes de inicializarlo.
  static FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;

  /// Obtiene un observer para añadir a navigatorObservers del MaterialApp o CupertinoApp.
  static FirebaseAnalyticsObserver getObserver() {
    return FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);
  }

  /// Método genérico para registrar un evento personalizado.
  ///
  /// [eventName] es el nombre del evento (ej: 'button_clicked', 'purchase_completed').
  /// [parameters] es un mapa opcional con los detalles adicionales a registrar.
  static Future<void> logEvent(String eventName,
      {Map<String, Object>? parameters}) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
      if (kDebugMode) {
        print(
            '✅ [AnalyticsService] Evento registrado: $eventName | params: $parameters');
      }
    } catch (e) {
      if (kDebugMode) {
        print(
            '❌ [AnalyticsService] Error al registrar evento ($eventName): $e');
      }
    }
  }

  /// Registrar vista de una pantalla manualmente si no se usa el observer.
  static Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
      );
      if (kDebugMode) {
        print('✅ [AnalyticsService] Pantalla registrada: $screenName');
      }
    } catch (e) {
      if (kDebugMode) {
        print(
            '❌ [AnalyticsService] Error al registrar pantalla ($screenName): $e');
      }
    }
  }

  /// Registrar o actualizar una propiedad del usuario.
  static Future<void> setUserProperty(String name, String value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      if (kDebugMode) {
        print(
            '✅ [AnalyticsService] Propiedad de usuario establecida: $name = $value');
      }
    } catch (e) {
      if (kDebugMode) {
        print(
            '❌ [AnalyticsService] Error al establecer propiedad de usuario ($name): $e');
      }
    }
  }

  /// Identificar un usuario con un ID específico.
  static Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      if (kDebugMode) {
        print('✅ [AnalyticsService] ID de usuario establecido: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print(
            '❌ [AnalyticsService] Error al establecer ID de usuario ($userId): $e');
      }
    }
  }
}
