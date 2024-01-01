import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String _baseURL = 'renewed-benches.000webhostapp.com';

class Engineering {
  int id;
  String name;
  double pricePerCredit;
  int nbOfCredits;
  String schoolName;

  Engineering(this.id, this.name, this.pricePerCredit, this.nbOfCredits, this.schoolName);

  @override
  String toString() {
    return 'ID: $id \nName: $name\nPrice per Credit: \$$pricePerCredit \nNumber of Credits: $nbOfCredits\nSchool Name: $schoolName';
  }
}

List<Engineering> eng = [];

void updateEng(Function(bool success) update) async {
  try {
    final url = Uri.https(_baseURL, 'show_eng.php');
    final response = await http.get(url).timeout(const Duration(seconds: 5));
    eng.clear();

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);

      if (jsonResponse is List) {
        for (var row in jsonResponse) {
          Engineering p = Engineering(
            int.tryParse(row['id'].toString()) ?? 0,
            row['name'] ?? '',
            double.tryParse(row['price_per_credit'].toString()) ?? 0.0,
            int.tryParse(row['nb_of_credits'].toString()) ?? 0,
            row['school_name'] ?? '',
          );
          eng.add(p);
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

void searchEng(Function(String text) update, int pid) async {
  try {
    final url = Uri.https(_baseURL, 'search_eng.php', {'id':'$pid'});
    final response = await http.get(url)
        .timeout(const Duration(seconds: 5));
    eng.clear();
    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);

      if (jsonResponse is List && jsonResponse.isNotEmpty) {
        var row = jsonResponse[0];
        Engineering p = Engineering(
          int.parse(row['id'].toString()),
          row['name'].toString(),
          double.parse(row['price_per_credit'].toString()),
          int.parse(row['nb_of_credits'].toString()),
          row['name'].toString(), // Use the correct key for school name
        );
        eng.add(p);
        update(p.toString());
      } else {
        update("No data found");
      }
    } else {
      update("Can't load data - HTTP Error: ${response.statusCode}");
    }
  } catch (e) {
    print('Error: $e');
    update("Can't load data. Error: ${e?.toString() ?? 'Unknown error'}");
  }
}
class ShowEng extends StatelessWidget {
  final List<Engineering> searchResults;

  const ShowEng({Key? key, required this.searchResults}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) => Column(
        children: [
          const SizedBox(height: 10),
          Container(
            color: index % 2 == 0 ? Colors.pink : Colors.grey,
            padding: const EdgeInsets.all(5),
            width: width * 0.9,
            child: Text(searchResults[index].toString(), style: TextStyle(fontSize: width * 0.045)),
          ),
        ],
      ),
    );
  }
}

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}
class _SearchState extends State<Search> {
  final TextEditingController _controllerID = TextEditingController();
  String _text = '';

  @override
  void dispose() {
    _controllerID.dispose();
    super.dispose();
  }

  void update(String? text) {
    setState(() {
      _text = text ?? "No data found";
    });
  }

  void getEng() {
    try {
      int pid = int.parse(_controllerID.text);
      searchEng(update, pid);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong arguments')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Engineering Major'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _controllerID,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter ID'),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: getEng,
              child: const Text('Search', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 10),
            Center(
              child: SizedBox(
                width: 200,
                child: Text(
                  _text,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}class Home1 extends StatefulWidget {
  const Home1({Key? key});

  @override
  State<Home1> createState() => _HomeState();
}

class _HomeState extends State<Home1> {
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
    updateEng(update);
  }

  @override
  Widget build(BuildContext context) {
    print("Building Homes widget");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey, // Set the background color to deep purple
        actions: [
          IconButton(
            onPressed: !_load
                ? null
                : () {
              setState(() {
                _load = false;
                updateEng(update);
              });
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Search(),
                  ),
                );
              });
            },
            icon: const Icon(Icons.search),
          ),
        ],
        title: const Text('Engineering Majors'),
        centerTitle: true,
      ),
      body: _load
          ? ShowEng(searchResults: eng)
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
      home: const Home1(),
    ),
  );
}
