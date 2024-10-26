import 'package:flutter/material.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:signals/signals_flutter.dart';
import 'dart:async';

class VoiceTransactionScreen extends StatefulWidget {
  final FinanceService financeService;

  const VoiceTransactionScreen({super.key, required this.financeService});

  @override
  _VoiceTransactionScreenState createState() => _VoiceTransactionScreenState();
}

class _VoiceTransactionScreenState extends State<VoiceTransactionScreen> {
  final isRecording = signal(false);
  final isProcessing = signal(false);
  final recordingDuration = signal(0);
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Transaction', style: theme.textTheme.headlineSmall),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Watch((context) {
              if (isProcessing.value) {
                return _buildProcessingUI(theme);
              }
              return _buildRecordingButton(theme);
            }),
            const SizedBox(height: 20),
            Watch((context) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isRecording.value
                    ? Column(
                        children: [
                          Text(
                            'Recording...',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${recordingDuration.value} seconds',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      )
                    : Text(
                        'Tap and hold to record',
                        style: theme.textTheme.titleLarge,
                      ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingButton(ThemeData theme) {
    return GestureDetector(
      onTapDown: (_) => _startRecording(),
      onTapUp: (_) => _stopRecording(),
      onTapCancel: _stopRecording,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isRecording.value
              ? theme.colorScheme.error
              : theme.colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: (isRecording.value
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary)
                  .withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          isRecording.value ? Icons.stop : Icons.mic,
          color: theme.colorScheme.onPrimary,
          size: 60,
        ),
      ),
    ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack);
  }

  Widget _buildProcessingUI(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primaryContainer,
          ),
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            strokeWidth: 8,
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .scaleXY(begin: 0.9, end: 1.1, duration: 1.seconds)
            .then()
            .scaleXY(begin: 1.1, end: 0.9, duration: 1.seconds),
        const SizedBox(height: 20),
        Text(
          'Processing your transaction...',
          style: theme.textTheme.titleMedium,
        ).animate().fadeIn(duration: 200.ms).then().shimmer(
            duration: 1.seconds,
            color: theme.colorScheme.primary.withOpacity(0.3)),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  void _startRecording() {
    isRecording.value = true;
    recordingDuration.value = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      recordingDuration.value++;
    });
    // TODO: Implement actual recording logic
  }

  void _stopRecording() async {
    if (!isRecording.value) return;

    isRecording.value = false;
    _timer?.cancel();
    isProcessing.value = true;

    // TODO: Implement actual recording stop and processing logic
    await Future.delayed(
        const Duration(seconds: 2)); // Simulating processing time

    isProcessing.value = false;
    // TODO: Navigate to suggestion screen
  }
}
