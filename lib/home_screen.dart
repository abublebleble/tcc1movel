import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'Usuário';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),  // Alterando cor da AppBar
        elevation: 0,
      ),
      drawer: _buildDrawer(context),
      backgroundColor: Colors.black,  // Fundo da HomeScreen preto
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bem-vindo, $userName!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade400,  // Ajustando cor do texto
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Aqui você pode ver e registrar seus progressos.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,  // Cor de fundo do menu
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 0, 0, 0),  // Cor de fundo do header
            ),
            accountName: Text(
              userName ?? 'Usuário',
              style: TextStyle(color: Colors.white),
            ),
            accountEmail: Text(
              'Bem-vindo, $userName',
              style: TextStyle(color: Colors.white70),
            ),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.person, size: 40, color: Colors.white),
              backgroundColor: Colors.grey.shade800,
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: 'Home',
            route: '/home',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.view_list,
            title: 'Ver Progressos',
            route: '/verprogresso',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.add,
            title: 'Registrar Progresso',
            route: '/criarprogresso',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            route: '/login',
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.clear();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade400),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      onTap: onTap ?? () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}
