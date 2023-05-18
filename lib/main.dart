import 'package:flutter/material.dart';

// firebase
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

// firestore
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Exemplo Firestore';

    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        body: UserInformation(),
      ),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  // controler para observar o TextFormField
  final myController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('nomes').snapshots();
  // Cria uma referência para a colecao nomes no firestore.
  CollectionReference nomes = FirebaseFirestore.instance.collection('nomes');

  // funcao que insere no firestore o nome passsado como parametro
  Future<void> adicionarNome(String nome) {
    return nomes
        .add({'nome': nome})
        .then((value) => print("Nome adicionado"))
        .catchError((error) => print("Erro ao adicionar: $error"));
  }

  Future<void> getNames() async {
    FirebaseFirestore.instance
        .collection('nomes')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        print("DOCS NAME:" + doc["nome"]);
        print("DOC ID:" + doc.id);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextFormField(
              controller: myController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe um nome';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  getNames();
                  adicionarNome(myController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Gravando dados no Firestore...')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

class UserInformation extends StatefulWidget {
  @override
  _UserInformationState createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('nomes').snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;

            return ListTile(
              title: Text(data["nome"]),
              trailing: const Icon(Icons.add),
            );
          }).toList(),
        );
      },
    );
  }
}
