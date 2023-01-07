import 'package:flutter/material.dart';
import 'package:mentoring_get_cep/src/view/detail_page.dart';
import 'package:mentoring_get_cep/src/view/list_page.dart';
import 'package:mentoring_get_cep/src/widget/default_button.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var cepFormatter = MaskTextInputFormatter(
      mask: '#####-###',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  String? _cep = '';

  final appBar = AppBar(
    backgroundColor: Colors.black87,
    title: const Text(
      'Busca CEP',
      style: TextStyle(color: Colors.white),
    ),
  );

  final fieldText = TextEditingController();

  void clearText() {
    fieldText.clear();

    setState(() {
      _cep = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: 200, child: Image.asset('assets/images/location.png')),
            Container(
              padding: const EdgeInsets.all(20),
              child: TextField(
                inputFormatters: [cepFormatter],
                keyboardType: TextInputType.number,
                maxLength: 9,
                decoration: InputDecoration(
                  labelText: 'Informe o CEP',
                  labelStyle: const TextStyle(
                    color: Color.fromRGBO(38, 63, 47, 1),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(38, 63, 47, 1),
                    ),
                  ),
                  suffixIcon: _cep!.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: Color.fromRGBO(38, 63, 47, 1)),
                          onPressed: clearText,
                        )
                      : null,
                ),
                controller: fieldText,
                onChanged: (cep) {
                  setState(() {
                    _cep = cep.toString();
                  });
                },
              ),
            ),
            DefaultButton(
              enabled: _cep!.isNotEmpty,
              label: 'Buscar',
              backgroundColor: const Color.fromRGBO(38, 63, 47, 1),
              labelColor: const Color.fromRGBO(133, 221, 164, 1),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailPage(cep: _cep ?? '')),
                );
              },
            ),
            const SizedBox(height: 10),
            DefaultButton(
              label: 'Ver Lista',
              backgroundColor: Colors.white,
              borderColor: const Color.fromRGBO(38, 63, 47, 1),
              labelColor: const Color.fromRGBO(38, 63, 47, 1),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ListPage()),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
