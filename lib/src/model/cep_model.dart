class CepModel {
  String? cep;
  String? tipologradouro;
  String? logradouro;
  String? numero;
  String? bairro;
  String? complemento;
  String? localidade;
  String? uf;

  CepModel({
    this.cep,
    this.tipologradouro,
    this.logradouro,
    this.numero,
    this.bairro,
    this.complemento,
    this.localidade,
    this.uf,
  });

  CepModel.fromJson(Map<String, dynamic> json) {
    cep = json['cep'];
    tipologradouro = json['tipologradouro'];
    logradouro = json['logradouro'];
    numero = json['numero'];
    bairro = json['bairro'];
    complemento = json['complemento'];
    localidade = json['localidade'];
    uf = json['uf'];
  }

  Map<String, dynamic> toMap() {
    return {
      'cep': cep,
      'tipologradouro': tipologradouro,
      'logradouro': logradouro,
      'numero': numero,
      'bairro': bairro,
      'complemento': complemento,
      'localidade': localidade,
      'uf': uf,
    };
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cep'] = cep;
    data['tipologradouro'] = tipologradouro;
    data['logradouro'] = logradouro;
    data['numero'] = numero;
    data['bairro'] = bairro;
    data['complemento'] = complemento;
    data['localidade'] = localidade;
    data['uf'] = uf;
    return data;
  }
}
