import 'dart:convert';

enum PaperSize {
  mm58,
  mm80,
}

enum PosAlign {
  left,
  center,
  right,
}

enum PosTextSize {
  size1,
  size2,
  size3,
  size4,
}

enum PosFontType {
  fontA,
  fontB,
}

class CapabilityProfile {
  const CapabilityProfile._();

  static Future<CapabilityProfile> load([String? name]) async {
    return const CapabilityProfile._();
  }
}

class PosStyles {
  final PosAlign align;
  final bool bold;
  final bool underline;
  final PosTextSize height;
  final PosTextSize width;
  final PosFontType fontType;

  const PosStyles({
    this.align = PosAlign.left,
    this.bold = false,
    this.underline = false,
    this.height = PosTextSize.size1,
    this.width = PosTextSize.size1,
    this.fontType = PosFontType.fontA,
  });
}

class PosColumn {
  final String text;
  final int width;
  final PosAlign alignment;

  const PosColumn({
    required this.text,
    this.width = 6,
    this.alignment = PosAlign.left,
  });
}

class Generator {
  final PaperSize paperSize;
  final CapabilityProfile profile;

  Generator(this.paperSize, this.profile);

  int get columns => paperSize == PaperSize.mm58 ? 32 : 48;

  List<int> _align(PosAlign align) {
    switch (align) {
      case PosAlign.left:
        return [0x1B, 0x61, 0x00];
      case PosAlign.center:
        return [0x1B, 0x61, 0x01];
      case PosAlign.right:
        return [0x1B, 0x61, 0x02];
    }
  }

  List<int> _bold(bool value) {
    return [0x1B, 0x45, value ? 1 : 0];
  }

  List<int> _size(PosTextSize size) {
    final int n = size.index.clamp(0, 3);
    final int value = (n << 4) | n;

    return [0x1D, 0x21, value];
  }

  List<int> text(
    String value, {
    PosStyles styles = const PosStyles(),
    bool containsChinese = false,
  }) {
    return [
      ..._align(styles.align),
      ..._bold(styles.bold),
      ..._size(styles.height),
      ...utf8.encode(value),
      0x0A,
      ..._size(PosTextSize.size1),
      ..._bold(false),
    ];
  }

  List<int> row(List<PosColumn> inputColumns) {
    final StringBuffer line = StringBuffer();

    for (final column in inputColumns) {
      final int width =
          (column.width.clamp(1, 12) * columns) ~/ 12;

      String value = column.text;

      if (value.length > width) {
        value = value.substring(0, width);
      }

      if (column.alignment == PosAlign.left) {
        value = value.padRight(width);
      } else if (column.alignment == PosAlign.right) {
        value = value.padLeft(width);
      } else {
        final int left = (width - value.length) ~/ 2;
        final int right = width - value.length - left;

        value =
            (' ' * left) +
            value +
            (' ' * right);
      }

      line.write(value);
    }

    return [
      ..._align(PosAlign.left),
      ...utf8.encode(line.toString()),
      0x0A,
    ];
  }

  List<int> feed(int lines) {
    return [
      0x1B,
      0x64,
      lines.clamp(0, 10),
    ];
  }

  List<int> cut() {
    return [0x1D, 0x56, 0x00];
  }

  List<int> reset() {
    return [0x1B, 0x40];
  }
}
