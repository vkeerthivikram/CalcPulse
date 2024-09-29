import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart'; // Add this package for graphing

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CalcPulse',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CalculatorHomePage(title: 'CalcPulse'),
    );
  }
}

enum CalculatorMode { simple, scientific, programmer, engineer, graph, business }

class CalculatorHomePage extends StatefulWidget {
  const CalculatorHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<CalculatorHomePage> createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage> {
  String _display = '0';
  String _currentInput = '';
  double _result = 0;
  String _operation = '';
  bool _shouldResetInput = false;
  List<String> _history = [];
  CalculatorMode _currentMode = CalculatorMode.simple;
  int _base = 10;
  String _graphEquation = 'y = x';
  List<FlSpot> _graphPoints = [];

  void _onButtonPressed(String buttonText) {
    setState(() {
      switch (_currentMode) {
        case CalculatorMode.simple:
          _handleSimpleCalculatorInput(buttonText);
          break;
        case CalculatorMode.scientific:
          _handleScientificCalculatorInput(buttonText);
          break;
        case CalculatorMode.programmer:
          _handleProgrammerCalculatorInput(buttonText);
          break;
        case CalculatorMode.engineer:
          _handleEngineerCalculatorInput(buttonText);
          break;
        case CalculatorMode.graph:
          _handleGraphCalculatorInput(buttonText);
          break;
        case CalculatorMode.business:
          _handleBusinessCalculatorInput(buttonText);
          break;
      }
    });
  }

  void _handleSimpleCalculatorInput(String buttonText) {
    if (buttonText == 'C') {
      _clear();
    } else if (buttonText == '=') {
      _calculateResult();
    } else if (['+', '-', '×', '÷'].contains(buttonText)) {
      _setOperation(buttonText);
    } else if (buttonText == '±') {
      _changeSign();
    } else if (buttonText == '%') {
      _calculatePercentage();
    } else if (buttonText == '.') {
      _addDecimalPoint();
    } else {
      _updateInput(buttonText);
    }
  }

  void _handleScientificCalculatorInput(String buttonText) {
    if (['sin', 'cos', 'tan', 'log', '√', '^'].contains(buttonText)) {
      _handleScientificFunction(buttonText);
    } else {
      _handleSimpleCalculatorInput(buttonText);
    }
  }

  void _handleProgrammerCalculatorInput(String buttonText) {
    if (['AND', 'OR', 'XOR', 'NOT', '<<', '>>'].contains(buttonText)) {
      _handleBitwiseOperation(buttonText);
    } else if (['HEX', 'DEC', 'OCT', 'BIN'].contains(buttonText)) {
      _changeBase(buttonText);
    } else {
      _updateInput(buttonText);
    }
  }

  void _handleEngineerCalculatorInput(String buttonText) {
    if (['sin⁻¹', 'cos⁻¹', 'tan⁻¹', '10^x', 'e^x', 'ln'].contains(buttonText)) {
      _handleEngineerFunction(buttonText);
    } else {
      _handleScientificCalculatorInput(buttonText);
    }
  }

  void _handleGraphCalculatorInput(String buttonText) {
    if (buttonText == 'Plot') {
      _plotGraph();
    } else {
      _updateInput(buttonText);
    }
  }

  void _plotGraph() {
    _graphEquation = _currentInput;
    _graphPoints = [];
    for (double x = -10; x <= 10; x += 0.1) {
      try {
        double y = _evaluateExpression(_graphEquation.replaceAll('x', x.toString()));
        _graphPoints.add(FlSpot(x, y));
      } catch (e) {
        // Skip invalid points
      }
    }
    setState(() {});
  }

  double _evaluateExpression(String expression) {
    // This is a simple implementation. For a more robust solution,
    // consider using a math expression parser library.
    return double.parse(expression);
  }

  void _handleBusinessCalculatorInput(String buttonText) {
    switch (buttonText) {
      case 'ROI':
        _calculateROI();
        break;
      case 'Markup':
        _calculateMarkup();
        break;
      case 'Discount':
        _calculateDiscount();
        break;
      default:
        _handleSimpleCalculatorInput(buttonText);
    }
  }

  void _calculateROI() {
    if (_currentInput.isNotEmpty) {
      List<String> values = _currentInput.split(',');
      if (values.length == 2) {
        double investment = double.parse(values[0]);
        double returns = double.parse(values[1]);
        double roi = ((returns - investment) / investment) * 100;
        _display = '${roi.toStringAsFixed(2)}%';
        _addToHistory('ROI($investment, $returns) = $_display');
      }
    }
  }

  void _calculateMarkup() {
    if (_currentInput.isNotEmpty) {
      List<String> values = _currentInput.split(',');
      if (values.length == 2) {
        double cost = double.parse(values[0]);
        double price = double.parse(values[1]);
        double markup = ((price - cost) / cost) * 100;
        _display = '${markup.toStringAsFixed(2)}%';
        _addToHistory('Markup($cost, $price) = $_display');
      }
    }
  }

  void _calculateDiscount() {
    if (_currentInput.isNotEmpty) {
      List<String> values = _currentInput.split(',');
      if (values.length == 2) {
        double originalPrice = double.parse(values[0]);
        double discountedPrice = double.parse(values[1]);
        double discount = ((originalPrice - discountedPrice) / originalPrice) * 100;
        _display = '${discount.toStringAsFixed(2)}%';
        _addToHistory('Discount($originalPrice, $discountedPrice) = $_display');
      }
    }
  }

  void _handleScientificFunction(String function) {
    if (_currentInput.isNotEmpty) {
      double value = double.parse(_currentInput);
      switch (function) {
        case 'sin':
          _result = sin(value * pi / 180);
          break;
        case 'cos':
          _result = cos(value * pi / 180);
          break;
        case 'tan':
          _result = tan(value * pi / 180);
          break;
        case 'log':
          _result = log(value) / ln10;
          break;
        case '√':
          _result = sqrt(value);
          break;
        case '^':
          _setOperation('^');
          return;
      }
      _display = _formatResult(_result);
      _addToHistory('$function($_currentInput) = $_display');
      _currentInput = '';
      _shouldResetInput = true;
    }
  }

  void _handleBitwiseOperation(String operation) {
    if (_currentInput.isNotEmpty) {
      int value = int.parse(_currentInput, radix: _base);
      switch (operation) {
        case 'AND':
          _setOperation('&');
          break;
        case 'OR':
          _setOperation('|');
          break;
        case 'XOR':
          _setOperation('^');
          break;
        case 'NOT':
          _result = (~value).toDouble();
          _display = _formatResult(_result, _base);
          break;
        case '<<':
          _setOperation('<<');
          break;
        case '>>':
          _setOperation('>>');
          break;
      }
    }
  }

  void _changeBase(String newBase) {
    if (_currentInput.isNotEmpty) {
      int value = int.parse(_currentInput, radix: _base);
      switch (newBase) {
        case 'HEX':
          _base = 16;
          _display = value.toRadixString(16).toUpperCase();
          break;
        case 'DEC':
          _base = 10;
          _display = value.toString();
          break;
        case 'OCT':
          _base = 8;
          _display = value.toRadixString(8);
          break;
        case 'BIN':
          _base = 2;
          _display = value.toRadixString(2);
          break;
      }
      _currentInput = _display;
    }
  }

  void _handleEngineerFunction(String function) {
    if (_currentInput.isNotEmpty) {
      double value = double.parse(_currentInput);
      switch (function) {
        case 'sin⁻¹':
          _result = asin(value) * 180 / pi;
          break;
        case 'cos⁻¹':
          _result = acos(value) * 180 / pi;
          break;
        case 'tan⁻¹':
          _result = atan(value) * 180 / pi;
          break;
        case '10^x':
          _result = pow(10, value).toDouble();
          break;
        case 'e^x':
          _result = exp(value);
          break;
        case 'ln':
          _result = log(value);
          break;
      }
      _display = _formatResult(_result);
      _addToHistory('$function($_currentInput) = $_display');
      _currentInput = '';
      _shouldResetInput = true;
    }
  }

  void _clear() {
    _display = '0';
    _currentInput = '';
    _result = 0;
    _operation = '';
    _shouldResetInput = false;
  }

  void _calculateResult() {
    if (_operation.isNotEmpty && _currentInput.isNotEmpty) {
      double secondOperand = double.parse(_currentInput);
      switch (_operation) {
        case '+':
          _result += secondOperand;
          break;
        case '-':
          _result -= secondOperand;
          break;
        case '×':
          _result *= secondOperand;
          break;
        case '÷':
          if (secondOperand != 0) {
            _result /= secondOperand;
          } else {
            _display = 'Error';
            return;
          }
          break;
      }
      _display = _formatResult(_result);
      _currentInput = '';
      _operation = '';
      _shouldResetInput = true;
    }
  }

  void _setOperation(String op) {
    if (_currentInput.isNotEmpty) {
      if (_operation.isNotEmpty) {
        _calculateResult();
      } else {
        _result = double.parse(_currentInput);
      }
      _operation = op;
      _shouldResetInput = true;
    } else if (_result != 0) {
      _operation = op;
    }
  }

  void _updateInput(String digit) {
    if (_shouldResetInput) {
      _currentInput = digit;
      _shouldResetInput = false;
    } else {
      _currentInput += digit;
    }
    _display = _currentInput;
  }

  void _changeSign() {
    if (_currentInput.isNotEmpty) {
      if (_currentInput.startsWith('-')) {
        _currentInput = _currentInput.substring(1);
      } else {
        _currentInput = '-' + _currentInput;
      }
      _display = _currentInput;
    } else if (_result != 0) {
      _result = -_result;
      _display = _formatResult(_result);
    }
  }

  void _calculatePercentage() {
    if (_currentInput.isNotEmpty) {
      double value = double.parse(_currentInput) / 100;
      _currentInput = _formatResult(value);
      _display = _currentInput;
    }
  }

  void _addDecimalPoint() {
    if (!_currentInput.contains('.')) {
      _currentInput += _currentInput.isEmpty ? '0.' : '.';
      _display = _currentInput;
    }
  }

  String _formatResult(double result, [int base = 10]) {
    if (base == 10) {
      String formatted = result.toStringAsFixed(8);
      return formatted.replaceAll(RegExp(r'([.]*0+)(?!.*\d)'), '');
    } else {
      return result.toInt().toRadixString(base).toUpperCase();
    }
  }

  void _addToHistory(String entry) {
    _history.insert(0, entry);
    if (_history.length > 10) {
      _history.removeLast();
    }
  }

  Widget _buildButton(String buttonText, {Color? color, double? width}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () => _onButtonPressed(buttonText),
          child: Text(
            buttonText,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSimpleCalculatorButtons() {
    return [
      Row(children: [
        _buildButton('C', color: Colors.redAccent),
        _buildButton('±'),
        _buildButton('%'),
        _buildButton('÷', color: Colors.orangeAccent),
      ]),
      Row(children: [
        _buildButton('7'),
        _buildButton('8'),
        _buildButton('9'),
        _buildButton('×', color: Colors.orangeAccent),
      ]),
      Row(children: [
        _buildButton('4'),
        _buildButton('5'),
        _buildButton('6'),
        _buildButton('-', color: Colors.orangeAccent),
      ]),
      Row(children: [
        _buildButton('1'),
        _buildButton('2'),
        _buildButton('3'),
        _buildButton('+', color: Colors.orangeAccent),
      ]),
      Row(children: [
        _buildButton('0', width: MediaQuery.of(context).size.width * 0.5),
        _buildButton('.'),
        _buildButton('=', color: Colors.orangeAccent),
      ]),
    ];
  }

  List<Widget> _buildScientificCalculatorButtons() {
    return [
      Row(children: [
        _buildButton('sin'),
        _buildButton('cos'),
        _buildButton('tan'),
        _buildButton('log'),
      ]),
      Row(children: [
        _buildButton('√'),
        _buildButton('^'),
        _buildButton('('),
        _buildButton(')'),
      ]),
      ..._buildSimpleCalculatorButtons(),
    ];
  }

  List<Widget> _buildProgrammerCalculatorButtons() {
    return [
      Row(children: [
        _buildButton('HEX'),
        _buildButton('DEC'),
        _buildButton('OCT'),
        _buildButton('BIN'),
      ]),
      Row(children: [
        _buildButton('AND'),
        _buildButton('OR'),
        _buildButton('XOR'),
        _buildButton('NOT'),
      ]),
      Row(children: [
        _buildButton('<<'),
        _buildButton('>>'),
        _buildButton('A'),
        _buildButton('B'),
      ]),
      Row(children: [
        _buildButton('C'),
        _buildButton('D'),
        _buildButton('E'),
        _buildButton('F'),
      ]),
      ..._buildSimpleCalculatorButtons(),
    ];
  }

  List<Widget> _buildEngineerCalculatorButtons() {
    return [
      Row(children: [
        _buildButton('sin⁻¹'),
        _buildButton('cos⁻¹'),
        _buildButton('tan⁻¹'),
        _buildButton('10^x'),
      ]),
      Row(children: [
        _buildButton('e^x'),
        _buildButton('ln'),
        _buildButton('π'),
        _buildButton('e'),
      ]),
      ..._buildScientificCalculatorButtons(),
    ];
  }

  List<Widget> _buildGraphCalculatorButtons() {
    return [
      Container(
        height: 200,
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: _graphPoints,
                isCurved: true,
                color: Colors.blue,
                dotData: FlDotData(show: false),
              ),
            ],
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: true),
            gridData: FlGridData(show: true),
          ),
        ),
      ),
      TextField(
        decoration: InputDecoration(
          hintText: 'Enter equation (e.g., 2*x + 1)',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => _currentInput = value,
      ),
      ElevatedButton(
        onPressed: _plotGraph,
        child: Text('Plot'),
      ),
    ];
  }

  List<Widget> _buildBusinessCalculatorButtons() {
    return [
      Row(children: [
        _buildButton('ROI', color: Colors.blueAccent),
        _buildButton('Markup', color: Colors.blueAccent),
        _buildButton('Discount', color: Colors.blueAccent),
      ]),
      Text('Enter values separated by comma (,)'),
      ..._buildSimpleCalculatorButtons(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PopupMenuButton<CalculatorMode>(
            onSelected: (CalculatorMode mode) {
              setState(() {
                _currentMode = mode;
                _clear();
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<CalculatorMode>>[
              const PopupMenuItem<CalculatorMode>(
                value: CalculatorMode.simple,
                child: Text('Simple'),
              ),
              const PopupMenuItem<CalculatorMode>(
                value: CalculatorMode.scientific,
                child: Text('Scientific'),
              ),
              const PopupMenuItem<CalculatorMode>(
                value: CalculatorMode.programmer,
                child: Text('Programmer'),
              ),
              const PopupMenuItem<CalculatorMode>(
                value: CalculatorMode.engineer,
                child: Text('Engineer'),
              ),
              const PopupMenuItem<CalculatorMode>(
                value: CalculatorMode.graph,
                child: Text('Graph'),
              ),
              const PopupMenuItem<CalculatorMode>(
                value: CalculatorMode.business,
                child: Text('Business'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _operation,
                    style: TextStyle(fontSize: 24, color: Colors.grey),
                  ),
                  Text(
                    _display,
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1),
          ..._getCurrentModeButtons(),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'Calculation History',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            for (var entry in _history)
              ListTile(
                title: Text(entry),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _display = entry.split(' = ')[1];
                    _currentInput = _display;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getCurrentModeButtons() {
    switch (_currentMode) {
      case CalculatorMode.simple:
        return _buildSimpleCalculatorButtons();
      case CalculatorMode.scientific:
        return _buildScientificCalculatorButtons();
      case CalculatorMode.programmer:
        return _buildProgrammerCalculatorButtons();
      case CalculatorMode.engineer:
        return _buildEngineerCalculatorButtons();
      case CalculatorMode.graph:
        return _buildGraphCalculatorButtons();
      case CalculatorMode.business:
        return _buildBusinessCalculatorButtons();
    }
  }
}