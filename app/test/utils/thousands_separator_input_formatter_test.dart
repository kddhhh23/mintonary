import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mintonary/utils/thousands_separator_input_formatter.dart';

void main() {
  const formatter = ThousandsSeparatorInputFormatter();

  TextEditingValue format(String value) => formatter.formatEditUpdate(
    const TextEditingValue(),
    TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    ),
  );

  test('숫자 입력에 천 단위 쉼표를 넣고 커서를 끝에 둔다', () {
    expect(format('1').text, '1');
    expect(format('1000').text, '1,000');
    expect(format('123456789').text, '123,456,789');
    expect(format('123456789').selection.baseOffset, 11);
  });

  test('붙여넣은 쉼표와 숫자가 아닌 문자를 정리한다', () {
    expect(format('₩ 1,234,567원').text, '1,234,567');
    expect(format('').text, '');
    expect(format('원').text, '');
  });

  test('표시용 변환과 저장용 쉼표 제거가 서로 대응한다', () {
    expect(formatWithThousandsSeparators(0), '0');
    expect(formatWithThousandsSeparators(100000), '100,000');
    expect(removeThousandsSeparators('100,000'), '100000');
  });
}
