// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CepDetail extends StatefulWidget {
  const CepDetail({
    Key? key,
    required this.cep,
    required this.tipologradouro,
    required this.logradouro,
    required this.numero,
    required this.bairro,
    required this.complemento,
    required this.localidade,
    required this.uf,
  }) : super(key: key);

  final String cep;
  final String tipologradouro;
  final String logradouro;
  final String numero;
  final String bairro;
  final String complemento;
  final String localidade;
  final String uf;

  static const String tableName = 'ceps';

  @override
  State<CepDetail> createState() => _CepDetailState();
}

class _CepDetailState extends State<CepDetail> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              widget.cep,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: widget.tipologradouro == '0'
                ? const Icon(Icons.home)
                : const Icon(Icons.work),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.logradouro +
                    ' - ' +
                    widget.numero +
                    ' - ' +
                    widget.complemento),
                Text(widget.bairro),
                Text(widget.localidade + ' - ' + widget.uf),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
