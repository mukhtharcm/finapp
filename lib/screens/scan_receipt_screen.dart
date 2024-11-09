import 'dart:convert';

import 'package:finapp/models/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finapp/models/suggested_transaction.dart';
import 'package:finapp/screens/edit_transaction_screen.dart';
import 'package:finapp/blocs/category/category_bloc.dart';
import 'package:finapp/blocs/auth/auth_bloc.dart';
import 'package:finapp/widgets/suggested_transaction_card.dart';
import 'package:finapp/utils/currency_utils.dart';

class ScanReceiptScreen extends StatefulWidget {
  final FinanceService financeService;

  const ScanReceiptScreen({
    super.key,
    required this.financeService,
  });

  @override
  State<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends State<ScanReceiptScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  List<SuggestedTransaction> _suggestedTransactions = [];
  final Map<SuggestedTransaction, bool> _addingStatus = {};

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _isProcessing = true);
        await _processImage(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _processImage(String imagePath) async {
    try {
      final pb = widget.financeService.pb;
      final dio = Dio(BaseOptions(baseUrl: pb.baseUrl));

      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imagePath,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      final response = await dio.post(
        '/app/api/process-receipt',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer ${pb.authStore.token}'},
        ),
      );

      final List<dynamic> transactionsJson =
          response.data is String ? json.decode(response.data) : response.data;

      setState(() {
        _suggestedTransactions = transactionsJson
            .map((json) => SuggestedTransaction.fromJson(json))
            .toList();
      });

      // Clean up the image file
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process receipt: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencySymbol = CurrencyUtils.getCurrencySymbol(
      context.read<AuthBloc>().state.preferredCurrency,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Receipt', style: theme.textTheme.headlineSmall),
      ),
      body: _suggestedTransactions.isEmpty
          ? Center(
              child: _isProcessing
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Processing receipt...',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ).animate().fadeIn(duration: 300.ms)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No receipt scanned',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Take a photo or choose from gallery',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _showImageSourceDialog,
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text('Add Receipt'),
                        ),
                      ],
                    ).animate().fadeIn(duration: 300.ms),
            )
          : ListView.builder(
              itemCount: _suggestedTransactions.length,
              itemBuilder: (context, index) {
                final transaction = _suggestedTransactions[index];
                final category = _findCategory(context, transaction.categoryId);

                return SuggestedTransactionCard(
                  transaction: transaction,
                  category: category,
                  currencySymbol: currencySymbol,
                  opacity: _addingStatus[transaction] == true ? 0.5 : 1.0,
                  onEdit: () => _editSuggestedTransaction(transaction),
                  onAdd: () => _addTransaction(transaction),
                );
              },
            ),
      floatingActionButton: _suggestedTransactions.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: _showImageSourceDialog,
              child: const Icon(Icons.add_a_photo),
            ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
    );
  }

  Category? _findCategory(BuildContext context, String categoryId) {
    final categoryState = context.read<CategoryBloc>().state;
    if (categoryState is CategorySuccess) {
      try {
        return categoryState.categories.firstWhere((c) => c.id == categoryId);
      } catch (_) {
        return null;
      }
    }
    return null;
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

  Future<void> _addTransaction(SuggestedTransaction transaction) async {
    setState(() {
      _addingStatus[transaction] = true;
    });

    try {
      final newTransaction = transaction.toTransaction(
        widget.financeService.getCurrentUserId()!,
      );
      await widget.financeService.addTransaction(newTransaction);

      setState(() {
        _suggestedTransactions.remove(transaction);
        _addingStatus.remove(transaction);
      });
    } catch (e) {
      setState(() {
        _addingStatus[transaction] = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add transaction: $e')),
        );
      }
    }
  }
}
