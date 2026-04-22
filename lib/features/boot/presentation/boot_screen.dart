import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../bloc/boot_bloc.dart';
import '../bloc/boot_event.dart';
import '../bloc/boot_state.dart';
import '../../../core/utils/permission_service.dart';

class BootScreen extends StatefulWidget {
  const BootScreen({super.key});
  @override State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BootBloc>().add(StartBootSequence());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocConsumer<BootBloc, BootState>(
            listener: (context, state) async {
              if (state is BootComplete) {
                final hasPerm = await PermissionService.hasMediaPermission();
                if (!mounted) return;
                if (hasPerm) {
                  Navigator.of(context).pushReplacementNamed('/launcher');
                } else {
                  Navigator.of(context).pushReplacementNamed('/permission');
                }
              }
            },
            builder: (context, state) {
              if (state is BootInProgress) {
                return ListView.builder(
                  itemCount: state.lines.length,
                  itemBuilder: (context, index) => _BootLineText(text: state.lines[index]),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _BootLineText extends StatelessWidget {
  final String text;
  const _BootLineText({required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.endsWith('[OK]')) {
      final baseText = text.substring(0, text.length - 4);
      return RichText(
        text: TextSpan(
          style: AppTypography.terminalText,
          children: [
            TextSpan(text: baseText),
            TextSpan(text: '[OK]', style: AppTypography.terminalText.copyWith(color: AppColors.cyan)),
          ],
        ),
      );
    }
    return Text(text, style: AppTypography.terminalText);
  }
}
