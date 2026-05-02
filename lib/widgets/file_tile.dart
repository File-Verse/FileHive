import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class FileTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String name, size;

  const FileTile({super.key, required this.icon, required this.color, required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
      subtitle: Text(size, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
      trailing: const Icon(Icons.more_vert, color: AppColors.textGrey),
    );
  }
}