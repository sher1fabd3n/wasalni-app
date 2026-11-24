import 'package:flutter/material.dart';
import 'package:users_app/methods/common_methods.dart';

/// معالج الأخطاء المركزي للتطبيق
class ErrorHandler {
  static final CommonMethods _commonMethods = CommonMethods();
  
  /// معالجة أخطاء API
  static void handleApiError(dynamic error, BuildContext context, {String? customMessage}) {
    String message = customMessage ?? 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
    
    if (error is String) {
      if (error.contains('network') || error.contains('connection')) {
        message = 'مشكلة في الاتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى.';
      } else if (error.contains('timeout')) {
        message = 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.';
      } else if (error.contains('permission')) {
        message = 'لا توجد صلاحيات كافية. يرجى التحقق من الإعدادات.';
      } else {
        message = error;
      }
    } else if (error is Exception) {
      message = 'خطأ: ${error.toString()}';
    }
    
    _commonMethods.displaySnackBar(message, context);
  }
  
  /// معالجة أخطاء Firebase
  static void handleFirebaseError(dynamic error, BuildContext context) {
    String message = 'حدث خطأ في الاتصال. يرجى المحاولة مرة أخرى.';
    
    if (error.toString().contains('network')) {
      message = 'مشكلة في الاتصال بالإنترنت.';
    } else if (error.toString().contains('permission')) {
      message = 'لا توجد صلاحيات كافية.';
    } else if (error.toString().contains('not-found')) {
      message = 'البيانات غير موجودة.';
    }
    
    _commonMethods.displaySnackBar(message, context);
  }
  
  /// معالجة أخطاء الموقع
  static void handleLocationError(dynamic error, BuildContext context) {
    String message = 'حدث خطأ في تحديد الموقع. يرجى التحقق من صلاحيات الموقع.';
    
    if (error.toString().contains('permission')) {
      message = 'يرجى السماح بالوصول إلى الموقع من إعدادات التطبيق.';
    } else if (error.toString().contains('disabled')) {
      message = 'خدمة الموقع معطلة. يرجى تفعيلها.';
    }
    
    _commonMethods.displaySnackBar(message, context);
  }
  
  /// معالجة أخطاء الخريطة
  static void handleMapError(dynamic error, BuildContext context) {
    String message = 'حدث خطأ في تحميل الخريطة. يرجى المحاولة مرة أخرى.';
    _commonMethods.displaySnackBar(message, context);
  }
  
  /// عرض حوار خطأ
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(buttonText ?? 'حسناً'),
            ),
          ],
        );
      },
    );
  }
}
