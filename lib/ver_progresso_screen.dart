import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VerProgressoScreen extends StatefulWidget {
  @override
  _VerProgressoScreenState createState() => _VerProgressoScreenState();
}

class _VerProgressoScreenState extends State<VerProgressoScreen> {
  List<dynamic> _progressos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProgressos();
  }

  Future<void> _fetchProgressos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final response = await http.get(
      Uri.parse('https://levels.domcloud.dev/api/progressos'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _progressos = data['progressos'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar progressos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ver Progresso'),
        backgroundColor: Colors.black,  // Black AppBar
        elevation: 0,
      ),
      body: Container(
        color: Colors.black,  // Black background for the body
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.green.shade400))
            : _progressos.isEmpty
                ? Center(child: Text('Nenhum progresso registrado', style: TextStyle(color: Colors.green.shade400, fontSize: 18)))
                : ListView.builder(
                    itemCount: _progressos.length,
                    itemBuilder: (context, index) {
                      var progresso = _progressos[index];
                      var nomeExercicio = progresso['exercicio_nome'] ?? 'Desconhecido';
                      var data = progresso['data'] ?? 'Data não disponível';
                      var carga = progresso['carga'] ?? 0;
                      var repeticoes = progresso['repeticoes_realizadas'] ?? 0;

                      return Card(
                        color: Colors.black.withOpacity(0.8),  // Dark background for each card
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.green.shade400, width: 1),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            'Exercício: $nomeExercicio',
                            style: TextStyle(color: Colors.green.shade400, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text(
                            'Data: $data\nCarga: ${carga}kg\nRepetições: ${repeticoes}',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
