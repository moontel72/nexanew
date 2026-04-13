import 'package:flutter/material.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';

class CodeGenerationSuccessDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onOk;
  final VoidCallback onViewCodes;

  const CodeGenerationSuccessDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onOk,
    required this.onViewCodes,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
      ),
      content: Text(
        content,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: onOk,
          child: Text(
            'OK',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                ),
          ),
        ),
        TextButton(
          onPressed: onViewCodes,
          child: Text(
            'View Codes',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}
