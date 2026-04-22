import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'bloc/terminal_bloc.dart';
import 'bloc/terminal_event.dart';
import 'bloc/terminal_state.dart';
import 'widgets/terminal_output_line.dart';
import 'widgets/terminal_input_field.dart';

class TerminalScreen extends StatelessWidget {
  const TerminalScreen({super.key});
  @override Widget build(BuildContext context) {
    return BlocProvider(create: (context) => TerminalBloc(), child: const _TerminalView());
  }
}

class _TerminalView extends StatefulWidget {
  const _TerminalView();
  @override State<_TerminalView> createState() => _TerminalViewState();
}

class _TerminalViewState extends State<_TerminalView> {
  final ScrollController _scrollController = ScrollController();
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 100), curve: Curves.easeOut);
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.termBg,
      appBar: AppBar(
        backgroundColor: AppColors.surface, title: Text('◉ PocketOS Terminal', style: AppTypography.systemLabel),
        leading: IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocConsumer<TerminalBloc, TerminalState>(
            listener: (context, state) => WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom()),
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController, itemCount: state.lines.length,
                      itemBuilder: (context, index) => TerminalOutputLineWidget(line: state.lines[index]),
                    ),
                  ),
                  TerminalInputField(
                    prompt: state.prompt, initialValue: state.currentInput, isExecuting: state is TerminalExecuting,
                    onSubmit: (input) => context.read<TerminalBloc>().add(SubmitCommand(input)),
                    onUpArrow: () => context.read<TerminalBloc>().add(const NavigateHistory(HistoryDirection.up)),
                    onDownArrow: () => context.read<TerminalBloc>().add(const NavigateHistory(HistoryDirection.down)),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
