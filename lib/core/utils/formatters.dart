String formatDA(num value) {
  final isNegative = value < 0;
  final v = value.abs();
  final parts = v.toStringAsFixed(2).split('.');
  final intPart = parts[0];
  final decPart = parts[1];
  final buffer = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write('.');
    buffer.write(intPart[i]);
  }
  return '${isNegative ? '-' : ''}$buffer,$decPart DA';
}