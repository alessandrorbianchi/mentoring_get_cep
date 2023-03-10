// ignore_for_file: unrelated_type_equality_checks

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mentoring_get_cep/src/http/rest_client.dart';
import 'package:mentoring_get_cep/src/model/cep_model.dart';
import 'package:mentoring_get_cep/src/widget/circular_indicator.dart';
import 'package:mentoring_get_cep/src/widget/default_button.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:mentoring_get_cep/src/widget/error_message.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mentoring_get_cep/src/view/list_page.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({
    Key? key,
    required this.cep,
  }) : super(key: key);

  final String cep;
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _restClient = RestClient(Dio());
  bool _enabled = true;

  static const String createCepsTableScript =
      "CREATE TABLE ceps(cep TEXT, tipologradouro TEXT, logradouro TEXT, numero TEXT, bairro TEXT, complemento TEXT, localidade TEXT, uf TEXT);";
  static const String tableName = 'ceps';

  CepModel? _cep;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text(
          'Detalhes',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              FutureBuilder<CepModel?>(
                future: _restClient.getCep(widget.cep),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularIndicator();
                  }

                  if (snapshot.hasError || snapshot.data?.cep == null) {
                    _enabled = false;
                    return const ErrorMessage(
                      text: 'Nenhum CEP Encontrado :(',
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    _cep = snapshot.data!;

                    return _itemCep(_cep);
                  }

                  return const CircularIndicator();
                },
              ),
              DefaultButton(
                enabled: _enabled,
                label: 'Salvar CEP',
                backgroundColor: const Color.fromRGBO(38, 63, 47, 1),
                labelColor: const Color.fromRGBO(133, 221, 164, 1),
                onTap: () async {
                  String numero = _cep!.numero.toString();

                  if (numero.isEmpty || numero == 'null') {
                    _showSnackBar('Preencha o campo "N??mero".');
                    return;
                  }

                  int result = await _getCep(_cep!);
                  if (result > 0) {
                    _showSnackBar(
                        'CEP j?? cadastrado para o mesmo n??mero e complemento!');
                    return;
                  }

                  if (_cep!.tipologradouro == null) {
                    _cep!.tipologradouro = '0';
                  }

                  await _saveCep(_cep!);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ListPage()),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemCep(CepModel? cep) {
    return Column(
      children: [
        ListTile(
          title: const Text('CEP'),
          subtitle: Text(cep!.cep ?? '-'),
          trailing: ToggleSwitch(
            minWidth: 90.0,
            initialLabelIndex: 0,
            cornerRadius: 20.0,
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.grey,
            inactiveFgColor: Colors.white,
            totalSwitches: 2,
            icons: const [Icons.home, Icons.work],
            //0, 1 (Residencial, Comercial)
            activeBgColors: const [
              [Color.fromRGBO(38, 63, 47, 1)],
              [Color.fromRGBO(38, 63, 47, 1)]
            ],
            onToggle: (index) {
              if (index == 0) {
                cep.tipologradouro = '0';
              } else if (index == 1) {
                cep.tipologradouro = '1';
              }
            },
          ),
        ),
        ListTile(
          title: const Text('Rua'),
          subtitle: Text(cep.logradouro ?? '-'),
        ),
        ListTile(
          title: const Text('N??mero'),
          subtitle: TextFormField(
            keyboardType: TextInputType.number,
            maxLength: 10,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Digite o n??mero da resid??ncia',
            ),
            initialValue: cep.numero,
            onChanged: (numero) {
              cep.numero = numero.toString();
            },
          ),
        ),
        ListTile(
          title: const Text('Bairro'),
          subtitle: Text(cep.bairro ?? '-'),
        ),
        ListTile(
          title: const Text('Complemento'),
          subtitle: TextFormField(
            maxLength: 50,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Digite o complemento',
            ),
            initialValue: cep.complemento,
            onChanged: (complemento) {
              cep.complemento = complemento.toString();
            },
          ),
        ),
        ListTile(
          title: const Text('Localidade'),
          subtitle: Text(cep.localidade ?? '-'),
        ),
        ListTile(
          title: const Text('UF'),
          subtitle: Text(cep.uf ?? '-'),
        ),
      ],
    );
  }

  Future<Database> _getDatabase() async {
    return openDatabase(
      await getDatabasesPath() + 'cep.db',
      onCreate: (db, version) {
        return db.execute(createCepsTableScript);
      },
      version: 1,
    );
  }

  Future<int> _getCep(CepModel cep) async {
    try {
      final Database db = await _getDatabase();

      var result = await db.query(tableName,
          columns: ['cep'],
          where: '"cep" = ? and "numero" = ? and "complemento" = ? ',
          whereArgs: [
            (cep.cep.toString()),
            (cep.numero.toString()),
            (cep.complemento.toString())
          ]);

      return result.length;
    } catch (err) {
      _showSnackBar('Erro ao consultar o CEP :(');
      throw ('Error when consulting zip code $err');
    }
  }

  Future<void> _saveCep(CepModel cep) async {
    try {
      final Database db = await _getDatabase();

      await db.insert(
        tableName,
        cep.toMap(),
      );
      _showSnackBar('CEP salvo com Sucesso :)');
    } catch (err) {
      _showSnackBar('Erro ao salvar o CEP :(');
      throw ('Error saving CEP $err');
    }
  }

  void _showSnackBar(String label) {
    final snackBar = SnackBar(
      content: Text(label),
      padding: const EdgeInsets.all(20),
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
