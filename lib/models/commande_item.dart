class CommandeItem {
  final String? id;
  final String commandeId;
  final String produitId;
  final String produitNom; // denormalized for display
  final int quantite;
  final double prixUnitaire;

  CommandeItem({
    this.id,
    required this.commandeId,
    required this.produitId,
    required this.produitNom,
    required this.quantite,
    required this.prixUnitaire,
  });
  CommandeItem copyWith({
    String? id,
    String? commandeId,
    String? produitId,
    String? produitNom,
    int? quantite,
    double? prixUnitaire,
  }) {
  return CommandeItem(
    id: id ?? this.id,
    commandeId: commandeId ?? this.commandeId,
    produitId: produitId ?? this.produitId,
    produitNom: produitNom ?? this.produitNom,
    quantite: quantite ?? this.quantite,
    prixUnitaire: prixUnitaire ?? this.prixUnitaire,
    );
  }

  double get sousTotal => quantite * prixUnitaire;

  factory CommandeItem.fromMap(Map<String, dynamic> map) {
    return CommandeItem(
      id: map['id']?.toString(),
      commandeId: map['commande_id']?.toString() ?? '',
      produitId: map['produit_id']?.toString() ?? '',
      produitNom: map['produit_nom'] ?? '',
      quantite: map['quantite'] ?? 1,
      prixUnitaire: (map['prix_unitaire'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'commande_id': commandeId,
      'produit_id': produitId,
      'produit_nom': produitNom,
      'quantite': quantite,
      'prix_unitaire': prixUnitaire,
    };
  }
}