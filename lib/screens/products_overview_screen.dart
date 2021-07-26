import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/employee_grid.dart';
import '../providers/employees.dart';

enum FilterOptions {
  Online,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnline = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Employees>(context, listen: false)
          .fetchAndSetEmployees()
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Next Company',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Online) {
                  _showOnline = true;
                } else {
                  _showOnline = false;
                }
              });
            },
            icon: Icon(Icons.more_vert, color: Colors.black),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only online'),
                value: FilterOptions.Online,
              ),
              PopupMenuItem(child: Text('Show all'), value: FilterOptions.All),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _refreshProducts(context),
              child: SingleChildScrollView(
                  child: Column(
                children: <Widget>[
                  EmployeesGrid(_showOnline),
                ],
              ))),
    );
  }

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Employees>(context).fetchAndSetEmployees();
  }
}
