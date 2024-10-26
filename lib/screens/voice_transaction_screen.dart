import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:signals/signals_flutter.dart';
import 'dart:async';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
// import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'dart:convert';
import 'package:finapp/models/suggested_transaction.dart';
import 'package:finapp/models/category.dart';

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
  final suggestedTransactions = ListSignal<SuggestedTransaction>([]);
  Timer? _timer;
  late AudioRecorder _audioRecorder;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
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
              } else if (suggestedTransactions.isNotEmpty) {
                return _buildSuggestedTransactionsList(theme);
              }
              return _buildRecordingButton(theme);
            }),
            const SizedBox(height: 20),
            Watch((context) {
              if (!isProcessing.value && suggestedTransactions.isEmpty) {
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
              }
              return const SizedBox.shrink();
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

  Widget _buildSuggestedTransactionsList(ThemeData theme) {
    return Expanded(
      child: ListView.builder(
        itemCount: suggestedTransactions.length,
        itemBuilder: (context, index) {
          final transaction = suggestedTransactions[index];
          final category = widget.financeService.categories.firstWhere(
            (c) => c.id == transaction.categoryId,
            orElse: () => Category(name: 'Uncategorized', icon: '❓'),
          );
          return ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  transaction.type == SuggestedTransactionType.expense
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.primaryContainer,
              child: Text(
                category.icon,
                style: TextStyle(
                  color: transaction.type == SuggestedTransactionType.expense
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
              ),
            ),
            title: Text(transaction.description),
            subtitle: Text(category.name),
            trailing: Text(
              '${transaction.type == SuggestedTransactionType.expense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: transaction.type == SuggestedTransactionType.expense
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _editTransaction(transaction),
          );
        },
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path =
            '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(RecordConfig(), path: path);
        _recordingPath = path; // Assign the path after successful start

        isRecording.value = true;
        recordingDuration.value = 0;
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          recordingDuration.value++;
        });
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (!isRecording.value) return;

    try {
      isRecording.value = false;
      _timer?.cancel();
      final path = await _audioRecorder.stop();
      isProcessing.value = true;

      if (path != null) {
        await _processAudio(path);
      } else {
        print('Recording failed: no audio file was created.');
        // TODO: Show an error message to the user
      }
    } catch (e) {
      print('Error stopping recording: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _processAudio(String audioPath) async {
    try {
      final pb = widget.financeService.pb;
      final dio = Dio(BaseOptions(baseUrl: pb.baseUrl));

      FormData formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioPath,
          filename: 'audio.m4a',
          contentType: MediaType('audio', 'm4a'),
        ),
      });

      final response = await dio.post(
        '/app/api/process-audio',
        data: formData,
        options:
            Options(headers: {'Authorization': 'Bearer ${pb.authStore.token}'}),
      );

      // Check if response.data is already a List or if it needs to be decoded
      final List<dynamic> transactionsJson =
          response.data is String ? json.decode(response.data) : response.data;

      suggestedTransactions.value = transactionsJson
          .map((json) => SuggestedTransaction.fromJson(json))
          .toList();

      // print('Suggested transactions: ${suggestedTransactions.value}');
      // print in a readable format
      debugPrint(suggestedTransactions.value
          .map((t) => '${t.amount} ${t.description} ${t.categoryId} ${t.type}')
          .join('\n'));

      isProcessing.value = false;
    } catch (e) {
      debugPrint('Error sending audio to server: $e');
      // TODO: Show an error message to the user
      isProcessing.value = false;
    }
  }

  void _editTransaction(SuggestedTransaction transaction) {
    // TODO: Implement edit functionality
    // This could open a dialog or navigate to a new screen for editing
  }
}
