
import 'package:flutter/material.dart';

import '../models/course.dart';
import '../screens/course_detail_page.dart';

enum _CourseCardAction {
  favorite,
  edit,
  delete,
}

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

  static const Color primaryColor = Color(0xFF1976D2);
  static const Color textColor = Color(0xFF26364A);
  static const Color mutedColor = Color(0xFF718096);

  String get _statusLabel {
    switch (course.status) {
      case 'done':
        return 'Selesai';
      case 'active':
        return 'Berjalan';
      default:
        return 'Terencana';
    }
  }

  Color get _statusColor {
    switch (course.status) {
      case 'done':
        return const Color(0xFF16A36A);
      case 'active':
        return const Color(0xFFE39428);
      default:
        return const Color(0xFF64748B);
    }
  }

  void _openDetail(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CourseDetailPage(course: course),
      ),
    );
  }

  void _handleAction(_CourseCardAction action) {
    switch (action) {
      case _CourseCardAction.favorite:
        onToggleFavorite?.call();
      case _CourseCardAction.edit:
        onEdit?.call();
      case _CourseCardAction.delete:
        onDelete?.call();
    }
  }

  Widget _buildActionMenu() {
    final List<PopupMenuEntry<_CourseCardAction>> items = [];

    if (showFavoriteButton && onToggleFavorite != null) {
      items.add(
        PopupMenuItem(
          value: _CourseCardAction.favorite,
          child: Row(
            children: [
              Icon(
                isFavorite
                    ? Icons.favorite_border_rounded
                    : Icons.favorite_rounded,
                color: Colors.red.shade600,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                isFavorite
                    ? 'Hapus dari Favorit'
                    : 'Tambahkan ke Favorit',
              ),
            ],
          ),
        ),
      );
    }

    if (onEdit != null) {
      items.add(
        const PopupMenuItem(
          value: _CourseCardAction.edit,
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20),
              SizedBox(width: 12),
              Text('Edit Kursus'),
            ],
          ),
        ),
      );
    }

    if (onDelete != null) {
      items.add(
        PopupMenuItem(
          value: _CourseCardAction.delete,
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: Colors.red.shade600,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Hapus Kursus',
                style: TextStyle(color: Colors.red.shade600),
              ),
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<_CourseCardAction>(
      tooltip: 'Pilihan Kursus',
      onSelected: _handleAction,
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      icon: const Icon(
        Icons.more_vert_rounded,
        color: mutedColor,
        size: 23,
      ),
      itemBuilder: (_) => items,
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _statusLabel,
        style: TextStyle(
          color: _statusColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 1.5,
      shadowColor: const Color(0xFF26364A).withValues(alpha: 0.07),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: Color(0xFFE8EEF5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _openDetail(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F5FA),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            course.code,
                            style: const TextStyle(
                              color: Color(0xFF45617E),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '${course.credits} SKS',
                          style: const TextStyle(
                            color: mutedColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        _buildStatusBadge(),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              _buildActionMenu(),
            ],
          ),
        ),
      ),
    );
  }
}
