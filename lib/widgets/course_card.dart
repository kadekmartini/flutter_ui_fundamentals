
import 'package:flutter/material.dart';

import '../models/course.dart';
import '../screens/course_detail_page.dart';

class InteractiveCourseCard extends StatelessWidget {
  const InteractiveCourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showFavoriteButton = false,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  final Course course;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showFavoriteButton;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final List<Widget> actions = [];

    if (showFavoriteButton) {
      actions.add(
        IconButton(
          tooltip: isFavorite ? 'Hapus dari Favorites' : 'Tambah ke Favorites',
          visualDensity: VisualDensity.compact,
          onPressed: onToggleFavorite,
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.blue.shade600,
          ),
        ),
      );
    }

    if (onEdit != null) {
      actions.add(
        IconButton(
          tooltip: 'Edit Course',
          visualDensity: VisualDensity.compact,
          onPressed: onEdit,
          icon: Icon(
            Icons.edit_outlined,
            color: Colors.blue.shade700,
          ),
        ),
      );
    }

    if (onDelete != null) {
      actions.add(
        IconButton(
          tooltip: 'Hapus Course',
          visualDensity: VisualDensity.compact,
          onPressed: onDelete,
          icon: Icon(
            Icons.close,
            color: Colors.blue.shade700,
          ),
        ),
      );
    }

    return Card(
      color: const Color(0xFFFBFDFF),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFC7D8E8),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        onTap: onTap ??
            () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CourseDetailPage(course: course),
                ),
              );
            },
        title: Text(
          course.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF23496D),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${course.code} • ${course.credits} SKS',
            style: const TextStyle(
              color: Color(0xFF60758A),
              fontSize: 13,
            ),
          ),
        ),
        trailing: actions.isEmpty
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: actions,
              ),
      ),
    );
  }
}
