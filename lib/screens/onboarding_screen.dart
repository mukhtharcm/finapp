import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/utils/currency_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finapp/blocs/auth/auth_bloc.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final AuthService authService;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
    required this.authService,
  });

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final TextEditingController _nameController = TextEditingController();
  String _selectedCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    _nameController.text = authState.userName;
    _selectedCurrency = authState.preferredCurrency;
  }

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to FinApp',
      description: 'Take control of your finances with ease.',
      icon: Icons.account_balance_wallet,
    ),
    OnboardingPage(
      title: 'Track Expenses',
      description: 'Easily record and categorize your expenses.',
      icon: Icons.money_off,
    ),
    OnboardingPage(
      title: 'Manage Income',
      description: 'Keep track of all your income sources.',
      icon: Icons.attach_money,
    ),
    OnboardingPage(
      title: 'Gain Insights',
      description: 'Get valuable insights into your spending habits.',
      icon: Icons.insights,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              ..._pages.map((page) => _buildPage(page)),
              _buildNamePage(),
              _buildCurrencyPage(),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: Theme.of(context).primaryColor),
                        onPressed: () {
                          _pageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      )
                    else
                      SizedBox(width: 48), // Placeholder for alignment
                    if (_currentPage < _pages.length + 1)
                      TextButton(
                        onPressed: _onSkip,
                        child: const Text('Skip'),
                      )
                    else
                      ElevatedButton(
                        onPressed: _onGetStarted,
                        child: const Text('Get Started'),
                      ),
                    if (_currentPage < _pages.length + 1)
                      IconButton(
                        icon: Icon(Icons.arrow_forward,
                            color: Theme.of(context).primaryColor),
                        onPressed: () {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      )
                    else
                      SizedBox(width: 48), // Placeholder for alignment
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(page.icon, size: 100, color: Theme.of(context).primaryColor)
              .animate()
              .scale(duration: 300.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 20),
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
        ],
      ),
    );
  }

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'What\'s your name?',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 40),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Your Name',
              border: OutlineInputBorder(),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
        ],
      ),
    );
  }

  Widget _buildCurrencyPage() {
    final theme = Theme.of(context);
    List<String> currencies = CurrencyUtils.getAllCurrencyCodes();
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Select your preferred currency',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary),
            ),
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<String>(
                  value: _selectedCurrency,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCurrency = newValue!;
                    });
                  },
                  items:
                      currencies.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(value),
                            const SizedBox(width: 8),
                            Text(
                              CurrencyUtils.getCurrencySymbol(value),
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down,
                      color: theme.colorScheme.primary),
                  dropdownColor: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  menuMaxHeight: 300, // Limit the height of the dropdown menu
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 300.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 20),
          Text(
            'You can change this later in settings',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms, duration: 300.ms),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < _pages.length + 2; i++) {
      indicators.add(
        i == _currentPage ? _indicator(true) : _indicator(false),
      );
    }
    return indicators;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade300,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  void _onSkip() {
    _pageController.animateToPage(
      _pages.length + 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _onGetStarted() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);

    // Update user's name and preferred currency using AuthBloc
    context.read<AuthBloc>().add(UpdateUserName(_nameController.text));
    context.read<AuthBloc>().add(UpdatePreferredCurrency(_selectedCurrency));

    widget.onComplete();
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });
}
