class Message {
  final int id;
  final String titre;
  final DateTime datePoste;
  final String contenu;
  final String author;

  Message({
    required this.id,
    required this.titre,
    required this.datePoste,
    required this.contenu,
    required this.author,
  });

  // ✅ Gérer les valeurs nulles avec `??`
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      titre: json['titre'] ?? "Sans titre",
      datePoste: json['datePoste'] != null ? DateTime.parse(json['datePoste']) : DateTime.now(),
      contenu: json['contenu'] ?? "Aucun contenu",
      author: json['user'] != null && json['user']['nom'] != null
          ? "${json['user']['prenom'] ?? ''} ${json['user']['nom']}"
          : "Utilisateur inconnu",
    );
  }
}