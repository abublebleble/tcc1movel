import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CriarProgressoScreen extends StatefulWidget {
  @override
  _CriarProgressoScreenState createState() => _CriarProgressoScreenState();
}

class _CriarProgressoScreenState extends State<CriarProgressoScreen> {
  final _dataController = TextEditingController();
  final _cargaController = TextEditingController();
  final _repeticoesController = TextEditingController();
  bool _isLoading = false;
  String? _exercicioId;
  List<dynamic> _exercicios = [];

  @override
  void initState() {
    super.initState();
    _fetchExercicios();
  }

  Future<void> _fetchExercicios() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final response = await http.get(
      Uri.parse('https://levels.domcloud.dev/api/exercicios/treino'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _exercicios = data;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar exercícios')),
      );
    }
  }

  Future<void> _createProgresso() async {
    setState(() {
      _isLoading = true;
    });

    if (_exercicioId == null ||
        _dataController.text.isEmpty ||
        _cargaController.text.isEmpty ||
        _repeticoesController.text.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todos os campos são obrigatórios!')),
      );
      return;
    }

    try {
      DateTime.parse(_dataController.text);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Formato de data inválido! Use AAAA-MM-DD')),
      );
      return;
    }

    double carga = 0;
    try {
      carga = double.parse(_cargaController.text);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Carga deve ser um número válido!')),
      );
      return;
    }

    int repeticoes = 0;
    try {
      repeticoes = int.parse(_repeticoesController.text);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Repetições deve ser um número inteiro válido!')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final response = await http.post(
      Uri.parse('https://levels.domcloud.dev/api/progressos'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'id_treino_exercicio': _exercicioId,
        'data': _dataController.text,
        'carga': carga,
        'repeticoes_realizadas': repeticoes,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Progresso registrado com sucesso!')),
      );
      Navigator.pop(context);
    } else {
      final data = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['error'] ?? 'Erro ao registrar progresso')),
      );
    }
  }

  // Função para mostrar o DatePicker
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2020);
    DateTime lastDate = DateTime(2101);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != initialDate)
      setState(() {
        _dataController.text = "${picked.toLocal()}".split(' ')[0]; // Formato AAAA-MM-DD
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Progresso'),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),  // Cor da AppBar verde
        elevation: 0,
      ),
      body: Container(
        color: Colors.black,  // Cor de fundo preto para o body
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Registrar Progresso',
                style: TextStyle(
                  color: Colors.green.shade400,  // Título em verde
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _exercicioId,
                hint: Text(
                  'Selecione o Exercício',
                  style: TextStyle(color: Colors.green.shade400),  // Cor do texto verde
                ),
                dropdownColor: Colors.black, // Fundo preto do dropdown
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.7), // Fundo preto
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green.shade400),
                  ),
                ),
                isExpanded: true,
                style: TextStyle(color: Colors.green.shade400),  // Cor do texto verde
                items: _exercicios.map((exercicio) {
                  return DropdownMenuItem<String>(
                    value: exercicio['id'].toString(),
                    child: Text(
                      exercicio['nome_exercicio'],
                      style: TextStyle(color: Colors.green.shade400),  // Cor do texto verde
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _exercicioId = value;
                  });
                },
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: _buildTextField(_dataController, 'Data (AAAA-MM-DD)', TextInputType.datetime),
                ),
              ),
              SizedBox(height: 10),
              _buildTextField(_cargaController, 'Carga (kg)', TextInputType.number),
              SizedBox(height: 10),
              _buildTextField(_repeticoesController, 'Repetições Realizadas', TextInputType.number),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.green.shade400))
                  : ElevatedButton(
                      onPressed: _createProgresso,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade400,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Registrar Progresso',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType type) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.green.shade400),  // Cor do texto verde
        filled: true,
        fillColor: Colors.black.withOpacity(0.7),  // Fundo preto
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade400),
        ),
      ),
      keyboardType: type,
      style: TextStyle(color: Colors.green.shade400),  // Cor do texto verde
    );
  }
}
