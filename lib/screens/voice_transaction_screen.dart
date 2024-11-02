import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:async';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:finapp/models/suggested_transaction.dart';
import 'package:finapp/models/category.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/screens/edit_transaction_screen.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finapp/blocs/category/category_bloc.dart';
import 'package:finapp/blocs/account/account_bloc.dart';
import 'package:finapp/widgets/suggested_transaction_card.dart';
import 'package:finapp/blocs/auth/auth_bloc.dart';
import 'package:finapp/utils/currency_utils.dart';

class VoiceTransactionScreen extends StatefulWidget {
  final FinanceService financeService;

  const VoiceTransactionScreen({super.key, required this.financeService});

  @override
  _VoiceTransactionScreenState createState() => _VoiceTransactionScreenState();
}

class _VoiceTransactionScreenState extends State<VoiceTransactionScreen>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _isProcessing = false;
  int _recordingDuration = 0;
  List<SuggestedTransaction> _suggestedTransactions = [];
  Timer? _timer;
  late AudioRecorder _audioRecorder;

  late AnimationController _addingController;
  final Map<SuggestedTransaction, bool> _addingStatus = {};

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _addingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    _addingController.dispose();
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
            if (_isProcessing)
              _buildProcessingUI(theme)
            else if (_suggestedTransactions.isNotEmpty)
              _buildSuggestedTransactionsList(theme)
            else
              _buildRecordingButton(theme),
            const SizedBox(height: 20),
            if (!_isProcessing && _suggestedTransactions.isEmpty)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isRecording
                    ? Column(
                        children: [
                          Text(
                            'Recording...',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '$_recordingDuration seconds',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      )
                    : Text(
                        'Tap and hold to record',
                        style: theme.textTheme.titleLarge,
                      ),
              ),
          ],
        ),
      ),
      floatingActionButton: _suggestedTransactions.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _addAllTransactions,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add All'),
            ).animate().scale(delay: 300.ms, duration: 200.ms)
          : null,
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
          color: _isRecording
              ? theme.colorScheme.error
              : theme.colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: (_isRecording
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary)
                  .withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          _isRecording ? Icons.stop : Icons.mic,
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
    final currencySymbol = CurrencyUtils.getCurrencySymbol(
      context.read<AuthBloc>().state.preferredCurrency,
    );

    return Expanded(
      child: ListView.builder(
        itemCount: _suggestedTransactions.length,
        itemBuilder: (context, index) {
          final transaction = _suggestedTransactions[index];
          final category = _findCategory(transaction.categoryId);

          return SuggestedTransactionCard(
            transaction: transaction,
            category: category,
            currencySymbol: currencySymbol,
            opacity: _addingStatus[transaction] == true
                ? 1.0 - _addingController.value
                : 1.0,
            onEdit: () => _editSuggestedTransaction(transaction),
            onAdd: () => _addTransaction(transaction),
          );
        },
      ),
    );
  }

  Category? _findCategory(String categoryId) {
    try {
      final categoryState = context.read<CategoryBloc>().state;
      if (categoryState is CategorySuccess) {
        return categoryState.categories.firstWhere((c) => c.id == categoryId);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _showInvalidCategoryDialog(SuggestedTransaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Invalid Category'),
          content: Text(
              'The suggested category for this transaction is invalid. Please edit the transaction to select a valid category.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Edit'),
              onPressed: () {
                Navigator.of(context).pop();
                _editTransaction(transaction);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path =
            '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(RecordConfig(), path: path);

        setState(() {
          _isRecording = true;
          _recordingDuration = 0;
        });

        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordingDuration++;
          });
        });
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      setState(() {
        _isRecording = false;
      });
      _timer?.cancel();
      final path = await _audioRecorder.stop();

      setState(() {
        _isProcessing = true;
      });

      if (path != null) {
        await _processAudio(path);
      } else {
        debugPrint('Recording failed: no audio file was created.');
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
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

      final List<dynamic> transactionsJson =
          response.data is String ? json.decode(response.data) : response.data;

      setState(() {
        _suggestedTransactions = transactionsJson
            .map((json) => SuggestedTransaction.fromJson(json))
            .toList();
      });

      final file = File(audioPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error sending audio to server: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _addTransaction(
      SuggestedTransaction suggestedTransaction) async {
    setState(() {
      _addingStatus[suggestedTransaction] = true;
    });

    try {
      await _addTransactionWithoutSnackbar(suggestedTransaction);

      // Start the fade-out animation
      await _addingController.forward();

      setState(() {
        _suggestedTransactions.remove(suggestedTransaction);
        _addingStatus.remove(suggestedTransaction);
      });

      _addingController.reset();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction added successfully'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      setState(() {
        _addingStatus[suggestedTransaction] = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add transaction: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _editTransaction(SuggestedTransaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen.suggested(
          transaction: transaction,
          onEdit: (editedTransaction) {
            int index = _suggestedTransactions.indexOf(transaction);
            if (index != -1) {
              _suggestedTransactions[index] = editedTransaction;
            }
          },
        ),
      ),
    );
  }

  Future<void> _addAllTransactions() async {
    // First validate all transactions
    final invalidTransactions = _suggestedTransactions.where((transaction) {
      final categoryState = context.read<CategoryBloc>().state;
      final accountState = context.read<AccountBloc>().state;

      final categoryExists = categoryState is CategorySuccess &&
          categoryState.categories
              .any((category) => category.id == transaction.categoryId);
      final accountExists = accountState is AccountSuccess &&
          accountState.accounts
              .any((account) => account.id == transaction.accountId);

      return !categoryExists || !accountExists;
    }).toList();

    if (invalidTransactions.isNotEmpty) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Invalid Transactions'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Some transactions have invalid categories or accounts and cannot be added:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                ...invalidTransactions.map((transaction) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '• ${transaction.description}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )),
                const SizedBox(height: 16),
                Text(
                  'Please edit these transactions before adding them.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _addValidTransactions();
                },
                child: const Text('Add Valid Only'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // If all transactions are valid, add them
    await _addValidTransactions();
  }

  Future<void> _addValidTransactions() async {
    final validTransactions = _suggestedTransactions.where((transaction) {
      final categoryState = context.read<CategoryBloc>().state;
      final accountState = context.read<AccountBloc>().state;

      final categoryExists = categoryState is CategorySuccess &&
          categoryState.categories
              .any((category) => category.id == transaction.categoryId);
      final accountExists = accountState is AccountSuccess &&
          accountState.accounts
              .any((account) => account.id == transaction.accountId);

      return categoryExists && accountExists;
    }).toList();

    int successCount = 0;
    int failCount = 0;

    for (var transaction in validTransactions) {
      try {
        await _addTransactionWithoutSnackbar(transaction);
        successCount++;
      } catch (e) {
        failCount++;
        debugPrint('Failed to add transaction: $e');
      }
    }

    // Remove successfully added transactions
    _suggestedTransactions.removeWhere((t) => validTransactions.contains(t));

    if (context.mounted) {
      String message;
      if (failCount == 0) {
        message = 'All transactions added successfully';
      } else if (successCount == 0) {
        message = 'Failed to add any transactions';
      } else {
        message = '$successCount transactions added, $failCount failed';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: failCount == 0
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _addTransactionWithoutSnackbar(
      SuggestedTransaction suggestedTransaction) async {
    final newTransaction = Transaction(
      userId: widget.financeService.getCurrentUserId()!,
      type: suggestedTransaction.type == SuggestedTransactionType.income
          ? TransactionType.income
          : TransactionType.expense,
      amount: suggestedTransaction.amount,
      description: suggestedTransaction.description,
      timestamp: DateTime.now(),
      categoryId: suggestedTransaction.categoryId,
      accountId: suggestedTransaction.accountId, // Add this line
      created: DateTime.now(),
    );

    try {
      await widget.financeService.addTransaction(newTransaction);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add transaction: $e')),
      );
      rethrow;
    }
  }

  void _editSuggestedTransaction(SuggestedTransaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen.suggested(
          transaction: transaction,
          onEdit: (editedTransaction) {
            setState(() {
              final index = _suggestedTransactions.indexOf(transaction);
              if (index != -1) {
                _suggestedTransactions[index] = editedTransaction;
              }
            });
          },
        ),
      ),
    );
  }
}
