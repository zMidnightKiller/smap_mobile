import '../models/smap_user.dart';
import '../../security/password_hasher.dart';

/// Semente que representa a "base pré-carregada a partir da base online do
/// SMAP". Numa instalação real, este conteúdo viria de uma sincronização
/// inicial com o SMAP online; aqui ele garante que o app já nasça funcional e
/// autenticável **offline**.
///
/// As credenciais abaixo são apenas para desenvolvimento/demonstração. Em
/// produção, os verificadores viriam do backend e nenhuma senha padrão seria
/// distribuída com o app.
class SmapSeedData {
  const SmapSeedData({this.hasher = const PasswordHasher()});

  final PasswordHasher hasher;

  /// Configuração de identidade visual padrão (equivalente ao `/public/config`
  /// do SMAP), usada enquanto o app está offline.
  static const Map<String, dynamic> defaultConfig = {
    'nome_empresa': 'SMAP',
    'cor_primaria': '#6366F1',
    'cor_secundaria': '#A855F7',
  };

  /// Credenciais de demonstração exibidas na tela de login para facilitar os
  /// testes offline.
  static const List<Map<String, String>> demoCredentials = [
    {'email': 'admin@smap.local', 'senha': 'Smap@2025', 'perfil': 'Administrador'},
    {'email': 'caixa@smap.local', 'senha': 'Vendas@123', 'perfil': 'Operador de Caixa'},
  ];

  /// Usuários iniciais com verificador PBKDF2 já derivado, prontos para login
  /// offline.
  List<SmapUser> users() {
    final now = DateTime.now();
    return [
      SmapUser(
        id: 'usr-admin',
        name: 'Ana Administradora',
        email: 'admin@smap.local',
        role: 'Administrador',
        passwordVerifier: hasher.derive('Smap@2025'),
        lastSyncedAt: now,
      ),
      SmapUser(
        id: 'usr-caixa',
        name: 'Carlos Caixa',
        email: 'caixa@smap.local',
        role: 'Operador de Caixa',
        passwordVerifier: hasher.derive('Vendas@123'),
        lastSyncedAt: now,
      ),
    ];
  }
}
