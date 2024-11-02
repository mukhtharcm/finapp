import 'package:flutter/material.dart';
import 'package:finapp/models/transaction.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finapp/blocs/transaction/transaction_bloc.dart';
import 'package:finapp/blocs/auth/auth_bloc.dart';
import 'package:finapp/widgets/transaction_form.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionType transactionType;

  const AddTransactionScreen({
    super.key,
    required this.transactionType,
  });

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionSuccess) {
          Navigator.pop(context);
        } else if (state is TransactionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to add transaction: ${state.error}')),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.transactionType == TransactionType.income
                    ? 'Add Income'
                    : 'Add Expense',
                style: theme.textTheme.headlineSmall,
              ),
            ),
            body: Stack(
              children: [
                TransactionForm(
                  onSubmit: (transaction) {
                    context
                        .read<TransactionBloc>()
                        .add(AddTransaction(transaction));
                  },
                ),
                BlocBuilder<TransactionBloc, TransactionState>(
                  builder: (context, state) {
                    if (state is TransactionLoading) {
                      return Container(
                        color: Colors.black54,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.onPrimary),
                              )
                                  .animate(
                                      onPlay: (controller) =>
                                          controller.repeat())
                                  .scaleXY(
                                      begin: 0.8, end: 1.2, duration: 600.ms)
                                  .then(delay: 600.ms)
                                  .scaleXY(
                                      begin: 1.2, end: 0.8, duration: 600.ms),
                              const SizedBox(height: 16),
                              Text(
                                'Adding transaction...',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(color: Colors.white),
                              )
                                  .animate()
                                  .fadeIn(duration: 300.ms)
                                  .then()
                                  .shimmer(
                                      duration: 1.seconds,
                                      color: Colors.white54),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
