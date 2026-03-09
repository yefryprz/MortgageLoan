import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Only allow numbers, commas, and one decimal point
    final regExp = RegExp(r'^\d*[0-9,]*\.?\d*$');
    if (!regExp.hasMatch(newValue.text)) {
      return oldValue;
    }

    String cleanText = newValue.text.replaceAll(',', '');

    // Split into integer and decimal parts
    final parts = cleanText.split('.');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    // Format integer part
    if (integerPart.isNotEmpty) {
      final intValue = int.tryParse(integerPart);
      if (intValue == null && integerPart != '') return oldValue;
      if (intValue != null) {
        integerPart = NumberFormat('#,###', 'en_US').format(intValue);
      }
    }

    String formattedText =
        integerPart + (decimalPart != null ? '.$decimalPart' : '');

    // Improved cursor position calculation
    int oldOffset = oldValue.selection.end;
    int oldTextLength = oldValue.text.length;
    int oldCommasBefore = 0;
    for (int i = 0; i < min(oldOffset, oldTextLength); i++) {
      if (oldValue.text[i] == ',') oldCommasBefore++;
    }
    int rawOffsetBefore = oldOffset - oldCommasBefore;

    // Digits added or removed
    int digitDiff = newValue.text.replaceAll(',', '').length -
        oldValue.text.replaceAll(',', '').length;
    int targetRawOffset = rawOffsetBefore + digitDiff;

    int newOffset = 0;
    int rawCount = 0;
    while (newOffset < formattedText.length && rawCount < targetRawOffset) {
      if (formattedText[newOffset] != ',') {
        rawCount++;
      }
      newOffset++;
    }

    return TextEditingValue(
      text: formattedText,
      selection:
          TextSelection.collapsed(offset: min(newOffset, formattedText.length)),
    );
  }
}
