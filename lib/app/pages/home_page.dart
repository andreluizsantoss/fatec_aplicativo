import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatec/app/widgets/chat_message.dart';
import 'package:fatec/app/widgets/custom_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //* Google SingIn
  final googleSignIn = GoogleSignIn();

  //* Criar Variável para receber o usuário logado
  User? _currentUser;

  //* Variável para carregar a imagem
  bool isLoading = false;

  //* Faço a verificação do Usuário logado
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      //* Feito o LOGOUT deve ser envolvido em um SETSTATE para reconhecer e recarregar a página
      setState(() {
        _currentUser = user;
      });
    });
  }

  //!Metodo de Login do Google
  Future<User?> _getUser() async {
    //* Verificação do Usuário logado
    if (_currentUser != null) return _currentUser;

    try {
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect();
      }

      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = authResult.user;
      return user;
    } catch (e) {
      return null;
    }
  }

  //! Método para enviar mensagem
  Future<void> _sendMessage({String? text, File? imgFile}) async {
    //* Depois que fizer a autenticação com o Google
    final User? user = await _getUser();

    //* Se mesmo o usuário fazendo o login e vier nullo mostrar o erro
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível fazer o login. tente Novamente!'),
          backgroundColor: Colors.red,
        ),
      );
    }

    //* DEPOIS DE EFETUAR O LOGIN
    //* Caso contrário incluir no DATA os dados do user

    //* Mudar para MAP quando enviar a imagem
    Map<String, dynamic> data = {
      'uid': user!.uid,
      'senderName': user.displayName,
      'senderPhotoUrl': user.photoURL,
      'time': Timestamp.now(),
    };

    //!Metodo de envio de imagem para o Firebase
    if (imgFile != null) {
      //* Quando começar a carregar a imagem
      setState(() {
        isLoading = true;
      });

      //! Crio a pasta onde vai salvar o arquivo
      var reference = FirebaseStorage.instance.ref().child(
            user.uid + DateTime.now().millisecondsSinceEpoch.toString(),
          );

      //! * Envio a imagem para o Storage
      //! Upload da imagem na pasta criada
      TaskSnapshot storageTask = await reference.putFile(imgFile);

      //! Pega a url da imagem enviada
      final url = await storageTask.ref.getDownloadURL();
      data['imgUrl'] = url;

      //* Quando terminar de carregar a imagem
      setState(() {
        isLoading = false;
      });
    }

    //! Código para antes de implementar o envio de imagem
    // FirebaseFirestore db = FirebaseFirestore.instance;
    // db.collection("messages").add({"text": text});

    //* Mudar para quando enviar a imagem
    if (text != null) data['text'] = text;

    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //*Colocar o nome na APPBAR
        title: Text(_currentUser != null
            ? 'Olá, ${_currentUser?.displayName}'
            : 'Chat App'),
        centerTitle: true,
        //* Colocar o botão de actions
        //* LOGOUT
        elevation: 0,
        actions: [
          _currentUser != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      googleSignIn.signOut();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Você saiu com sucesso!!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.exit_to_app,
                    ),
                  ),
                )
              : Container(),
        ],
      ),

      //* Mudar para mostrar as mesangens na Tela
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              //* Ordenando as mensagens pelo timestamp
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('time')
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> docs =
                        snapshot.data!.docs.reversed.toList();
                    return ListView.builder(
                      itemCount: docs.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        var message = docs[index];
                        //* Depois de feito o login com o Google
                        return ChatMessage(
                          msg: docs[index].data() as Map<String, dynamic>,
                          //* Faz a verificação se quem esta mandando a mensagem sou eu
                          mine: message['uid'] == _currentUser?.uid,
                        );

                        //!Mostrando as mensagens
                        // return ListTile(
                        //   title: Text(msg['text']),
                        // );
                      },
                    );
                }
              },
            ),
          ),
          //* Mostrar Carregamento quando esta enviando mensagem
          isLoading ? const LinearProgressIndicator() : Container(),

          CustomText(sendMessage: _sendMessage),
        ],
      ),

      //! Mostrando o campo de envio de mensagem
      // body: CustomText(sendMessage: _sendMessage),
    );
  }
}
