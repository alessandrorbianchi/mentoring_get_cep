import 'package:flutter/material.dart';
import 'package:mentoring_get_cep/src/model/cep_model.dart';
import 'package:mentoring_get_cep/src/widget/circular_indicator.dart';
import 'package:mentoring_get_cep/src/widget/default_button.dart';
import 'package:mentoring_get_cep/src/widget/error_message.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mentoring_get_cep/src/view/list_page.dart';
import 'package:toggle_switch/toggle_switch.dart';

class EditPage extends StatefulWidget {
  const EditPage({
    Key? key,
    required this.cep,
    required this.numero,
    required this.complemento,
  }) : super(key: key);

  final String cep;
  final String numero;
  final String complemento;

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  static const String tableName = 'ceps';

  CepModel? _cep;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text(
          'Editar CEP',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              FutureBuilder<CepModel?>(
                future: _getCepEdit(
                  widget.cep,
                  widget.numero,
                  widget.complemento,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularIndicator();
                  }

                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    _cep = snapshot.data!;

                    return _itemCep(_cep);
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return const ErrorMessage(
                      text: 'Nenhum CEP Encontrado :(',
                    );
                  }

                  return const CircularIndicator();
                },
              ),
              DefaultButton(
                label: 'Salvar CEP',
                backgroundColor: const Color.fromRGBO(38, 63, 47, 1),
                labelColor: const Color.fromRGBO(133, 221, 164, 1),
                onTap: () async {
                  String numero = _cep!.numero.toString();

                  if (numero.isEmpty || numero == 'null') {
                    _showSnackBar('Preencha o campo "Número".');
                    return;
                  }

                  int result = await _getCep(_cep!);
                  if (result > 0) {
                    _showSnackBar(
                        'CEP já cadastrado para o mesmo número e complemento!');
                    return;
                  }

                  await _updateCep(_cep!);
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

  Future<Database> _getDatabase() async {
    return openDatabase(
      await getDatabasesPath() + 'cep.db',
    );
  }

  Future<CepModel> _getCepEdit(
      String cep, String numero, String complemento) async {
    try {
      final Database db = await _getDatabase();
      final List<Map<String, dynamic>> maps = await db.query(tableName,
          where: '"cep" = ? and "numero" = ? and "complemento" = ? ',
          whereArgs: [
            (cep.toString()),
            (numero.toString()),
            (complemento.toString())
          ]);

      return CepModel.fromJson(maps[0]);
    } catch (err) {
      _showSnackBar('Erro ao consultar o CEP :(');
      throw ('Error when consulting zip code $err');
    }
  }

  Future<int> _getCep(CepModel cep) async {
    try {
      final Database db = await _getDatabase();

      var result = await db.query(tableName,
          columns: ['cep'],
          where:
              '"cep" = ? and "numero" = ? and "complemento" = ? and "tipologradouro" = ? ',
          whereArgs: [
            (cep.cep.toString()),
            (cep.numero.toString()),
            (cep.complemento.toString()),
            (cep.tipologradouro.toString()),
          ]);

      return result.length;
    } catch (err) {
      _showSnackBar('Erro ao consultar o CEP :(');
      throw ('Error when consulting zip code $err');
    }
  }

  Widget _itemCep(CepModel? cep) {
    var isSelected = cep!.tipologradouro.toString() == '0' ? 0 : 1;
    return Column(
      children: [
        ListTile(
          title: const Text('CEP'),
          subtitle: Text(cep.cep ?? '-'),
          trailing: ToggleSwitch(
            minWidth: 90.0,
            initialLabelIndex: isSelected,
            cornerRadius: 20.0,
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.grey,
            inactiveFgColor: Colors.white,
            totalSwitches: 2,
            icons: const [Icons.home, Icons.work],
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
          title: const Text('Número'),
          subtitle: TextFormField(
            keyboardType: TextInputType.number,
            maxLength: 10,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Digite o número da residência',
            ),
            initialValue: cep.numero ?? '',
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

  Future<void> _updateCep(CepModel cep) async {
    try {
      final Database db = await _getDatabase();

      await db.update(
        tableName,
        cep.toMap(),
        where: "cep = ? and numero = ? and complemento = ?",
        whereArgs: [
          widget.cep,
          widget.numero,
          widget.complemento,
        ],
      );

      _showSnackBar('CEP alterado com Sucesso :)');
    } catch (err) {
      _showSnackBar('Erro ao alterar o CEP :(');
      throw ('Error change CEP $err');
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
