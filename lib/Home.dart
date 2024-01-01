import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'engineering.dart';
import 'education.dart';
import 'pharmacy.dart';
import 'Business.dart';
import 'ArtAndSciences.dart';

const String _baseURL = 'renewed-benches.000webhostapp.com';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LIU Schools App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to LIU'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://upload.wikimedia.org/wikipedia/ar/archive/4/4b/20170617001001%21LIU_Logo.png',
              height: 200, // Adjust the height as needed
              width: 200,  // Adjust the width as needed
            ),
            const SizedBox(height: 20),
            const Text(
              'Dear New Students,\nCongratulations on starting your university journey! Get ready for a transformative experience filled with diverse learning, lifelong friendships, and the chance to unleash your full potential. Embrace challenges, join the vibrant university community, and savor every moment of this extraordinary adventure. Your days ahead are a unique chapter waiting to be written – here\'s to a journey of growth, resilience, and endless possibilities.\n\nBest wishes,\n(LIU Community)',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              },
              child: const Text('Let us start ==>'),
            ),
          ],
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _load = false;

  void update(bool success) {
    setState(() {
      _load = true;
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load data')),
        );
      }
    });
  }

  @override
  void initState() {
    updateSchools(update);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                updateSchools(update);
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
        title: const Text('LIU SCHOOLS'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const WelcomePage()),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: _load
          ? const ShowSchools()
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

class schools {
  int id;
  String name;
  int nb_of_majors;
  String telephone;

  schools(this.id, this.name, this.nb_of_majors, this.telephone);

  @override
  String toString() {
    return 'ID: $id \nName: $name\nnb_of_majors: $nb_of_majors \ntelephone: \n$telephone';
  }
}

List<schools> _schools = [];

void updateSchools(Function(bool success) update) async {
  try {
    final url = Uri.https(_baseURL, 'show_schools.php');
    final response = await http.get(url).timeout(const Duration(seconds: 5));
    _schools.clear();
    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      for (var row in jsonResponse) {
        schools p = schools(
          int.parse(row['id']),
          row['name'],
          int.parse(row['nb_of_majors']),
          row['telephone'],
        );
        _schools.add(p);
      }
      update(true);
    }
  } catch (e) {
    update(false);
  }
}
class ShowSchools extends StatelessWidget {
  const ShowSchools({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return ListView.builder(
      itemCount: _schools.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Home1()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Home3()),
            );
          }else if(index==1){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Home2()),
            );

          }else if(index==3){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Home4()),
            );

          }
          else if(index==4){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Home5()),
            );

          }
        },
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              color: index % 2 == 0 ?Colors.grey : Colors.pink,
              padding: const EdgeInsets.all(5),
              width: width * 0.9,
              child: Row(
                children: [
                  SizedBox(width: width * 0.15),
                  Flexible(
                    child: Text(
                      _schools[index].toString(),
                      style: TextStyle(fontSize: width * 0.045),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
