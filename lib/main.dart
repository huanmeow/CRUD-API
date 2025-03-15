import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Game Shop',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AccountListScreen(),
    );
  }
}

class AccountListScreen extends StatefulWidget {
  @override
  _AccountListScreenState createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  late Future<List<dynamic>> _accounts;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  void _fetchAccounts() {
    setState(() {
      _accounts = ApiService.fetchAccounts();
    });
  }

  void _addAccount() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String game = _roleController.text.trim();
    String price = _priceController.text.trim();

    if (username.isEmpty || password.isEmpty || game.isEmpty || price.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vui lòng nhập đủ thông tin!")));
      return;
    }

    bool success = await ApiService.addAccount(username, password, game, int.parse(price));
    if (success) {
      _usernameController.clear();
      _passwordController.clear();
      _roleController.clear();
      _priceController.clear();
      _fetchAccounts();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Thêm tài khoản thành công!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Thêm tài khoản thất bại!")));
    }
  }

  void _editAccount(int id, String username, String password, String game, int price) {
    _usernameController.text = username;
    _passwordController.text = password;
    _roleController.text = game;
    _priceController.text = price.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Chỉnh sửa tài khoản"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _usernameController, decoration: InputDecoration(labelText: "Tài khoản")),
              TextField(controller: _passwordController, decoration: InputDecoration(labelText: "Mật khẩu"), obscureText: true),
              TextField(controller: _roleController, decoration: InputDecoration(labelText: "Loại")),
              TextField(controller: _priceController, decoration: InputDecoration(labelText: "Giá")),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Hủy"),
            ),
            TextButton(
              onPressed: () async {
                bool success = await ApiService.updateAccount(
                  id,
                  _usernameController.text.trim(),
                  _passwordController.text.trim(),
                  _roleController.text.trim(),
                  int.parse(_priceController.text.trim()),
                );
                if (success) {
                  _fetchAccounts();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cập nhật thành công!")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cập nhật thất bại!")));
                }
              },
              child: Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount(int id) async {
    bool success = await ApiService.deleteAccount(id);
    if (success) {
      _fetchAccounts();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Xóa tài khoản thành công!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Xóa tài khoản thất bại!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Danh sách tài khoản game")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _usernameController, decoration: InputDecoration(labelText: "Tài khoản"))),
                Expanded(child: TextField(controller: _passwordController, decoration: InputDecoration(labelText: "Mật khẩu"), obscureText: true)),
                Expanded(child: TextField(controller: _roleController, decoration: InputDecoration(labelText: "Loại"))),
                Expanded(child: TextField(controller: _priceController, decoration: InputDecoration(labelText: "Giá"))),
                IconButton(icon: Icon(Icons.add, color: Colors.blue), onPressed: _addAccount),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _accounts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Lỗi: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("Không có tài khoản nào"));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var account = snapshot.data![index];
                    return Card(
                      child: ListTile(
                        title: Text("Tài khoản: ${account['username']}"),
                        subtitle: Text("Mật khẩu: ${account['password']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: Icon(Icons.edit), onPressed: () => _editAccount(account['id'], account['username'], account['password'], account['game'], account['price'])),
                            IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteAccount(account['id'])),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
