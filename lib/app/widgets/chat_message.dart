import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  //*Recebe por parametros os dados
  final Map<String, dynamic> msg;

  //*Variável para saber se é minha mensagem
  final bool mine;

  const ChatMessage({
    Key? key,
    required this.msg,
    required this.mine,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      child: Row(
        children: [
          //* Se a mensagem NÃO É MINHA
          !mine
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(msg['senderPhotoUrl']),
                  ),
                )
              : Container(),
          Expanded(
            child: Column(
              //* Verificar quem mandou a mensagem para colocar o ALINHAMENTO
              crossAxisAlignment:
                  mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                msg['imgUrl'] != null
                    ? Image.network(
                        msg['imgUrl'],
                        width: 250,
                      )
                    : Text(
                        msg['text'],
                        //* Se a mensagem for minha alinhamento END
                        textAlign: mine ? TextAlign.end : TextAlign.start,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                Text(
                  msg['senderName'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          //* Se a mensagem É MINHA
          mine
              ? Padding(
                  //* Muda o alinhamento da margem para Esquenda
                  padding: const EdgeInsets.only(left: 16),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(msg['senderPhotoUrl']),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
