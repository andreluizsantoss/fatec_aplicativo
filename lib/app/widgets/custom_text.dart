import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CustomText extends StatefulWidget {
  //! Criar um função que recebe parametros
  final Function({String? text, File? imgFile}) sendMessage;

  //! Adiciona no método construtor
  const CustomText({
    Key? key,
    required this.sendMessage,
  }) : super(key: key);

  @override
  State<CustomText> createState() => _CustomTextState();
}

class _CustomTextState extends State<CustomText> {
  //! Pegar o texto digitado e enviar pelo botão SEND
  final _messageEC = TextEditingController();

  //! Cria uma variável para habilitar ou não o botão de enviar mensagem
  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            //! Envia a foto tirada
            onPressed: () async {
              final imgFile = await ImagePicker()
                  .pickImage(source: ImageSource.camera, imageQuality: 50);
              if (imgFile == null) return;
              widget.sendMessage(imgFile: File(imgFile.path));
            },
            icon: const Icon(
              Icons.photo_camera,
            ),
          ),
          Expanded(
            child: TextField(
              //! Insere a controller
              controller: _messageEC,
              //! Colocando como COLLAPSED - ficará bem comprimido na parte debaixo
              decoration: const InputDecoration.collapsed(
                hintText: 'Enviar uma mensagem',
              ),
              //! Função que vai ser chamada quando modificarmos algo nesse campo
              onChanged: (text) {
                //! Verifica - se estiver digitando = TRUE / caso contrario = FALSE
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              //! Função que vai ser chamada quando tocarmos no botão do teclado
              onSubmitted: (text) {
                //! Chama a função de enviar o texto
                widget.sendMessage(text: text);
                //! Limpa o texto digitado no campo
                _messageEC.clear();
                setState(() {
                  _isComposing = false;
                });
              },
            ),
          ),
          IconButton(
            //! De acordo com o _composing habilita ou não o botão
            onPressed: _isComposing
                ? () {
                    //! Chama a função de enviar o texto
                    widget.sendMessage(text: _messageEC.text);
                    //! Limpa o texto digitado no campo
                    _messageEC.clear();
                    setState(() {
                      _isComposing = false;
                    });
                  }
                : null,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
