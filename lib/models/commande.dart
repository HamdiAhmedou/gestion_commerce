import 'commande_item.dart';

enum StatutCommande { enAttente, confirmee, livree, annulee }

extension StatutCommandeExt on StatutCommande {
  String get value {
    switch (this) {
      case StatutCommande.enAttente:   return 'en_attente';
      case StatutCommande.confirmee:   return 'confirmee';
      case StatutCommande.livree:      return 'livree';
      case StatutCommande.annulee:     return 'annulee';
    }
  }

  static StatutCommande fromString(String s) {
    switch (s) {
      case 'confirmee':  return StatutCommande.confirmee;
      case 'livree':     return StatutCommande.livree;
      case 'annulee':    return StatutCommande.annulee;
      default:           return StatutCommande.enAttente;
    }
  }
}

class Commande {
  final String? id;
  final String clientId;
  final String clientNom; // denormalized for display
  final double total;
  final StatutCommande statut;
  final List<CommandeItem> items;
  final DateTime? createdAt;

  Commande({
    this.id,
    required this.clientId,
    required this.clientNom,
    required this.total,
    this.statut = StatutCommande.enAttente,
    this.items = const [],
    this.createdAt,
  });

  factory Commande.fromMap(Map<String, dynamic> map) {
    return Commande(
      id: map['id']?.toString(),
      clientId: map['client_id']?.toString() ?? '',
      clientNom: map['client_nom'] ?? '',
      total: (map['total'] as num).toDouble(),
      statut: StatutCommandeExt.fromString(map['statut'] ?? ''),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'client_id': clientId,
      'client_nom': clientNom,
      'total': total,
      'statut': statut.value,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  Commande copyWith({
    String? id,
    String? clientId,
    String? clientNom,
    double? total,
    StatutCommande? statut,
    List<CommandeItem>? items,
  }) {
    return Commande(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientNom: clientNom ?? this.clientNom,
      total: total ?? this.total,
      statut: statut ?? this.statut,
      items: items ?? this.items,
      createdAt: createdAt,
    );
  }
}