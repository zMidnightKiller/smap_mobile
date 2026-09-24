/// Representa um usuário do SMAP espelhado localmente para operação offline.
///
/// Este registro faz parte da "base pré-carregada" sincronizada a partir do
/// SMAP online. Contém apenas dados necessários para autenticar e identificar
/// o usuário no dispositivo — nunca a senha em texto puro, apenas o verificador
/// derivado ([passwordVerifier]).
class SmapUser {
  const SmapUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.passwordVerifier,
    this.avatarUrl,
    this.lastSyncedAt,
  });

  final String id;
  final String name;
  final String email;
  final String role;

  /// Verificador PBKDF2 usado para login offline. Pode ser nulo enquanto o
  /// usuário nunca autenticou neste dispositivo.
  final String? passwordVerifier;

  final String? avatarUrl;
  final DateTime? lastSyncedAt;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  SmapUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? passwordVerifier,
    String? avatarUrl,
    DateTime? lastSyncedAt,
  }) {
    return SmapUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      passwordVerifier: passwordVerifier ?? this.passwordVerifier,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'passwordVerifier': passwordVerifier,
      'avatarUrl': avatarUrl,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  factory SmapUser.fromMap(Map<String, dynamic> map) {
    return SmapUser(
      id: map['id'] as String,
      name: (map['name'] ?? '') as String,
      email: ((map['email'] ?? '') as String).toLowerCase(),
      role: (map['role'] ?? 'user') as String,
      passwordVerifier: map['passwordVerifier'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      lastSyncedAt: map['lastSyncedAt'] != null
          ? DateTime.tryParse(map['lastSyncedAt'] as String)
          : null,
    );
  }

  /// Constrói a partir do payload de usuário retornado pela API do SMAP.
  factory SmapUser.fromApi(Map<String, dynamic> json) {
    return SmapUser(
      id: (json['id'] ?? json['uuid'] ?? json['email']).toString(),
      name: (json['nome'] ?? json['name'] ?? '') as String,
      email: ((json['email'] ?? '') as String).toLowerCase(),
      role: (json['perfil'] ?? json['role'] ?? 'user').toString(),
      avatarUrl: json['avatar'] as String?,
      lastSyncedAt: DateTime.now(),
    );
  }
}
