// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mentoring_get_cep/src/model/cep_model.dart';
import 'package:mentoring_get_cep/src/widget/cep_detail.dart';
import 'package:mentoring_get_cep/src/widget/circular_indicator.dart';
import 'package:mentoring_get_cep/src/widget/default_dismissible.dart';
import 'package:mentoring_get_cep/src/widget/error_message.dart';
import 'package:mentoring_get_cep/src/view/edit_page.dart';
import 'package:sqflite/sqflite.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  static const String tableName = 'ceps';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text(
          'Lista de CEP',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FutureBuilder<List<CepModel>>(
          future: _getCeps(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularIndicator();
            }

            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              List<CepModel> ceps = snapshot.data!;

              if (ceps.isEmpty) {
                return const ErrorMessage(
                  text: 'Nenhum CEP Encontrado :(',
                );
              }
              return _listCeps(ceps);
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const ErrorMessage(
                text: 'Nenhum CEP Encontrado :(',
              );
            }

            return const CircularIndicator();
          },
        ),
      ),
    );
  }

  Widget _listCeps(List<CepModel> ceps) {
    return ListView.builder(
      itemCount: ceps.length,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemBuilder: (context, index) {
        return DefaultDismissible(
          chave: Key(ceps[index].toString()),
          alertDialogTitle: const Text('Excluir CEP'),
          alertDialogContext: Text('Excluir o CEP ${ceps[index].cep}?'),
          builderEdit: (context) => EditPage(
            cep: ceps[index].cep.toString(),
            numero: ceps[index].numero.toString(),
            complemento: ceps[index].complemento.toString(),
          ),
          actionButton: [
            FlatButton(
              onPressed: () async {
                Navigator.pop(context, 'Cancel');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListPage(),
                  ),
                );
              },
              child: const Text('Cancel'),
            ),
            FlatButton(
              onPressed: () async {
                Navigator.pop(context, 'OK');
                await _deleteCep(
                  ceps[index].cep.toString(),
                  ceps[index].numero.toString(),
                  ceps[index].complemento.toString(),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListPage(),
                  ),
                );
                _showSnackBar('CEP excluído com Sucesso :)');
              },
              child: const Text('OK'),
            ),
          ],
          childDetail: CepDetail(
            cep: ceps[index].cep!,
            tipologradouro: ceps[index].tipologradouro!,
            logradouro: ceps[index].logradouro!,
            numero: ceps[index].numero ?? '',
            bairro: ceps[index].bairro!,
            complemento: ceps[index].complemento ?? '',
            localidade: ceps[index].localidade!,
            uf: ceps[index].uf!,
          ),
        );
      },
    );
  }

  Future<Database> _getDatabase() async {
    return openDatabase(
      await getDatabasesPath() + 'cep.db',
    );
  }

  Future<List<CepModel>> _getCeps() async {
    try {
      final Database db = await _getDatabase();
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
      );

      return List.generate(maps.length, (i) {
        return CepModel.fromJson(maps[i]);
      });
    } catch (err) {
      throw ('Error get List CEP $err');
    }
  }

  Future<int> _deleteCep(String cep, String numero, String complemento) async {
    try {
      final Database db = await _getDatabase();

      return await db.delete(
        CepDetail.tableName,
        where: '"cep" = ? and "numero" = ? and "complemento" = ? ',
        whereArgs: [cep, numero, complemento],
      );
    } catch (err) {
      throw ('Error delete CEP $err');
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
