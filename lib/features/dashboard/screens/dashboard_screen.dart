import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/top_expenses_card.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/add_transaction_dialog.dart';
import '../../../core/models/transaction_model.dart';
import '../../../main_screen/main_screen.dart'; // Import MainScreen

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController _dashboardController = DashboardController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _configureStatusBar();
  }

  void _configureStatusBar() {
    final brightness = Theme.of(context).brightness;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: brightness,
      ),
    );
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddTransactionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: _dashboardController.getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No transactions yet'),
            );
          }

          var transactions = snapshot.data ?? [];
          transactions
              .sort((a, b) => b.date.compareTo(a.date)); // Sort by newest first
          final stats = _dashboardController.calculateStats(transactions);
          final topExpenses = _dashboardController.getTopExpenses(transactions);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                //final isLandscape = constraints.maxWidth > constraints.maxHeight;
                final screenWidth = constraints.maxWidth;

                final crossAxisCount = screenWidth < 600 ? 2 : 3;

                final titles = ['Expenses', 'Budget', 'Income', 'Top Expenses'];
                final amounts = [
                  stats[2].toDouble(),
                  stats[1].toDouble(),
                  stats[0].toDouble(),
                  0.0
                ];
                final icons = [
                  Icons.money_off,
                  Icons.account_balance_wallet,
                  Icons.attach_money,
                  Icons.money_off
                ];
                final iconColors = [Colors.red, null, Colors.green, null];

                return Column(
                  children: [
                    const DashboardHeader(),
                    Expanded(
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    // Calculate ideal height for top expenses (icon + title + 3 items)
                                    final idealHeight =
                                        MediaQuery.of(context).size.width /
                                            crossAxisCount *
                                            0.7;

                                    return GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        childAspectRatio: (constraints
                                                    .maxWidth -
                                                32) /
                                            (crossAxisCount *
                                                idealHeight), // Account for padding
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                      itemCount: 4,
                                      itemBuilder: (context, index) {
                                        // Common onTap handler
                                        void navigateToAnalytics() {
                                          final mainScreenState =
                                              context.findAncestorStateOfType<
                                                  MainScreenState>();
                                          mainScreenState?.navigateToIndex(
                                              2); // Navigate to Analytics (index 2)
                                        }

                                        if (index < 3) {
                                          // Wrap StatCard with InkWell
                                          return InkWell(
                                            onTap: navigateToAnalytics,
                                            child: StatCard(
                                              title: titles[index],
                                              amount: amounts[index],
                                              icon: icons[index],
                                              iconColor: iconColors[index],
                                            ),
                                          );
                                        } else {
                                          // Wrap TopExpensesCard with InkWell
                                          return InkWell(
                                            onTap: navigateToAnalytics,
                                            child: TopExpensesCard(
                                                topExpenses: topExpenses),
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                                SizedBox(height: constraints.maxHeight * 0.4),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: constraints.maxHeight * 0.4,
                            // Wrap Card with InkWell
                            child: InkWell(
                              onTap: () {
                                // Find MainScreenState and navigate
                                final mainScreenState = context
                                    .findAncestorStateOfType<MainScreenState>();
                                mainScreenState?.navigateToIndex(
                                    1); // Navigate to Transactions (index 1)
                              },
                              child: Card(
                                margin: EdgeInsets.zero,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          16),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 16),
                                      // Make title non-interactive if needed, or keep as is
                                      ExcludeSemantics(
                                        child: Text(
                                          'Recent Transactions',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Ignore pointer events for the list itself to ensure the InkWell captures the tap
                                      Expanded(
                                        child: IgnorePointer(
                                          child: RecentTransactionsList(
                                              transactions: transactions),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
