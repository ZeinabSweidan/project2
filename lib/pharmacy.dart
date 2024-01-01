import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String _baseURL = 'renewed-benches.000webhostapp.com';

class Pharmacy {
  int id;
  String name;
  double pricePerCredit;
  int nbOfCredits;
  String schoolName;

  Pharmacy(this.id, this.name, this.pricePerCredit, this.nbOfCredits, this.schoolName);

  @override
  String toString() {
    return 'ID: $id \nName: $name\nPrice per Credit: $pricePerCredit \nNumber of Credits: $nbOfCredits\nSchool Name: $schoolName';
  }
}

List<Pharmacy> ph = [];


void updatePh(Function(bool success) update) async {
  try {
    final url = Uri.https(_baseURL, 'show_pharm.php');
    final response = await http.get(url).timeout(const Duration(seconds: 5));
    ph.clear();

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);

      if (jsonResponse is List) {
        for (var row in jsonResponse) {
          Pharmacy p = Pharmacy(
            int.tryParse(row['id'].toString()) ?? 0,
            row['name'] ?? '',
            double.tryParse(row['price_per_credit'].toString()) ?? 0.0,
            int.tryParse(row['nb_of_credits'].toString()) ?? 0,
            row['school_name'] ?? '',
          );
          ph.add(p);
        }
        update(true);
      } else {
        print('Unexpected JSON structure: $jsonResponse');
        update(false);
      }
    } else {
      print('HTTP Error: ${response.statusCode}');
      update(false);
    }
  } catch (e) {
    print('Error: $e');
    update(false);
  }
}


class ShowPh extends StatelessWidget {
  const ShowPh({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return ListView.builder(
      itemCount: ph.length,
      itemBuilder: (context, index) => Column(
        children: [
          const SizedBox(height: 10),
          Container(
            color: index % 2 == 0 ? Colors.pink : Colors.grey,
            padding: const EdgeInsets.all(5),
            width: width * 0.9,
            child: Text(ph[index].toString(), style: TextStyle(fontSize: width * 0.045)),
          ),
        ],
      ),
    );
  }
}

class Home2 extends StatefulWidget {
  const Home2({super.key});

  @override
  State<Home2> createState() => _HomeState();
}

class _HomeState extends State<Home2> {
  bool _load = false;

  void update(bool success) {
    setState(() {
      _load = true;
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('failed to load data')));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    print("Initializing _HomeState");
    updatePh(update);
  }

  @override
  Widget build(BuildContext context) {
    print("Building Homes widget");
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.grey,
        actions: [
          IconButton(
            onPressed: !_load
                ? null
                : () {
              setState(() {
                _load = false;
                updatePh(update);
              });
            },
            icon: const Icon(Icons.refresh),
          ),

        ],
        title: const Text('Pharmacy Majors'),
        centerTitle: true,
      ),
      body: _load
          ? const ShowPh()
          : const Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: const Home2(),
    ),
  );
}