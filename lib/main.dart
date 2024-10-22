import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CurrencyConverterHomePage(),
    );
  }
}

class CurrencyConverterHomePage extends StatefulWidget {
  const CurrencyConverterHomePage({super.key});

  @override
  _CurrencyConverterHomePageState createState() =>
      _CurrencyConverterHomePageState();
}

class _CurrencyConverterHomePageState extends State<CurrencyConverterHomePage> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedCurrencyFrom = 'MDL';
  String _selectedCurrencyTo = 'USD';
  String _convertedAmount = '';
  double _sellRate = 0; // Selling rate (USD -> MDL)
  double _buyRate = 0;  // Buying rate (MDL -> USD)
  bool _loading = false;

  // Replace 'YOUR_API_KEY' with your valid API key for the exchange rate API
  final String apiUrl =
      'https://v6.exchangerate-api.com/v6/71942c4b736425d61920cbe0/latest/USD';

  @override
  void initState() {
    super.initState();
    _fetchExchangeRates();
  }

  Future<void> _fetchExchangeRates() async {
    setState(() {
      _loading = true;
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Assuming the API returns rates for USD
          _sellRate = data['conversion_rates']['MDL'] + 0.05; // Example margin
          _buyRate = data['conversion_rates']['MDL'] - 0.05;  // Example margin
        });
      } else {
        throw Exception('Failed to load exchange rate');
      }
    } catch (e) {
      print('Error fetching exchange rates: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildCurrencyInput(),
                  const SizedBox(height: 16),
                  _buildSwapButton(),
                  const SizedBox(height: 16),
                  _buildConvertedAmount(),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _convertCurrency, // Conversion logic here
                    child: const Text('Convert'),
                  ),
                  const SizedBox(height: 32),
                  _buildExchangeRateInfo(),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrencyInput() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.network(
                _selectedCurrencyFrom == 'MDL'
                    ? 'https://flagcdn.com/w320/md.png'
                    : 'https://flagcdn.com/w320/us.png',
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedCurrencyFrom,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCurrencyFrom = newValue!;
                  });
                },
                items: <String>['MDL', 'USD']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '1000.00',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwapButton() {
    return IconButton(
      icon: const Icon(Icons.swap_vert, size: 32),
      onPressed: () {
        setState(() {
          // Swap currencies
          String temp = _selectedCurrencyFrom;
          _selectedCurrencyFrom = _selectedCurrencyTo;
          _selectedCurrencyTo = temp;
        });
      },
    );
  }

  Widget _buildConvertedAmount() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.network(
                _selectedCurrencyTo == 'USD'
                    ? 'https://flagcdn.com/w320/us.png'
                    : 'https://flagcdn.com/w320/md.png',
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedCurrencyTo,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCurrencyTo = newValue!;
                  });
                },
                items: <String>['USD', 'MDL']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  enabled: false, // Converted amount should not be editable
                  controller: TextEditingController(
                      text: _convertedAmount.isEmpty ? '0.00' : _convertedAmount),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeRateInfo() {
    return Column(
      children: [
        const Text(
          'Indicative Exchange Rate',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '1 USD =',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _sellRate.toStringAsFixed(2),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'MDL',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Conversion logic
  void _convertCurrency() {
    double amount = double.tryParse(_amountController.text) ?? 0;

    if (_selectedCurrencyFrom == 'USD') {
      // Convert USD to MDL using sell rate
      _convertedAmount = (amount * _sellRate).toStringAsFixed(2);
    } else {
      // Convert MDL to USD using buy rate
      _convertedAmount = (amount / _buyRate).toStringAsFixed(2);
    }

    setState(() {});
  }
}
