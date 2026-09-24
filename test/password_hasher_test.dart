import 'package:flutter_test/flutter_test.dart';
import 'package:smap_mobile/src/security/password_hasher.dart';

void main() {
  const hasher = PasswordHasher(iterations: 1000);

  group('PasswordHasher', () {
    test('deriva um verificador que não contém a senha em texto puro', () {
      final encoded = hasher.derive('Smap@2025');
      expect(encoded, startsWith('pbkdf2\$1000\$'));
      expect(encoded.contains('Smap@2025'), isFalse);
    });

    test('verifica a senha correta', () {
      final encoded = hasher.derive('Smap@2025');
      expect(hasher.verify('Smap@2025', encoded), isTrue);
    });

    test('rejeita senha incorreta', () {
      final encoded = hasher.derive('Smap@2025');
      expect(hasher.verify('senhaErrada', encoded), isFalse);
    });

    test('salt aleatório produz verificadores diferentes para a mesma senha', () {
      final a = hasher.derive('mesmaSenha');
      final b = hasher.derive('mesmaSenha');
      expect(a, isNot(equals(b)));
      expect(hasher.verify('mesmaSenha', a), isTrue);
      expect(hasher.verify('mesmaSenha', b), isTrue);
    });

    test('verificador malformado retorna falso sem lançar', () {
      expect(hasher.verify('x', 'formato-invalido'), isFalse);
    });
  });
}
