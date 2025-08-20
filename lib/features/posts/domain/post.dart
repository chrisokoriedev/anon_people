import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Post {
  Post({
    required this.id,
    required this.content,
    required this.createdAt,
    this.authorTag,
    this.revealTag = false,
  });

  final String id;
  final String content;
  final DateTime createdAt;
  final String? authorTag;
  final bool revealTag;

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as String,
        content: (json['content'] as String?)?.trim() ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        authorTag: json['authorTag'] as String?,
        revealTag: (json['revealTag'] as bool?) ?? false,
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'authorTag': authorTag,
        'revealTag': revealTag,
      };

  factory Post.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final ts = data['createdAt'];
    DateTime created;
    if (ts is Timestamp) {
      created = ts.toDate();
    } else if (ts is int) {
      created = DateTime.fromMillisecondsSinceEpoch(ts);
    } else if (ts is String) {
      created = DateTime.tryParse(ts) ?? DateTime.now();
    } else {
      created = DateTime.now();
    }
    return Post(
      id: doc.id,
      content: (data['content'] as String?)?.trim() ?? '',
      authorTag: data['authorTag'] as String?,
      revealTag: (data['revealTag'] as bool?) ?? false,
      createdAt: created,
    );
  }

  String get createdAtLabel {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h';
    }
    return DateFormat('MMM d').format(createdAt);
  }
}


