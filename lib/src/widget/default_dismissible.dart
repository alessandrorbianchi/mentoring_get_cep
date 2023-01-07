// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class DefaultDismissible extends StatelessWidget {
  const DefaultDismissible({
    Key? key,
    required this.chave,
    required this.childDetail,
    required this.actionButton,
    required this.alertDialogTitle,
    required this.alertDialogContext,
    required this.builderEdit,
  }) : super(key: key);

  final dynamic chave;
  final Widget childDetail;
  final List<Widget> actionButton;
  final Text alertDialogTitle;
  final Text alertDialogContext;
  final Widget Function(BuildContext) builderEdit;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          return true;
        } else if (direction == DismissDirection.endToStart) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: builderEdit,
            ),
          );
        }
        return null;
      },
      secondaryBackground: Container(
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Icon(Icons.edit, color: Colors.white),
              Text('Editar CEP', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
      background: Container(
        color: Colors.red,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: const [
              Icon(Icons.delete, color: Colors.white),
              Text('Excluir CEP', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
      key: chave,
      onDismissed: (DismissDirection direction) async {
        if (direction == DismissDirection.startToEnd) {
          return await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: alertDialogTitle,
                content: alertDialogContext,
                actions: actionButton,
              );
            },
          );
        }
      },
      child: childDetail,
    );
  }
}
