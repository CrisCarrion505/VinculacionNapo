class ValidarCedulaEcuador {
  static bool validar(String cedula) {
    if (cedula.length != 10) {
      return false;
    }

    // Verificar que todos los caracteres sean dígitos
    if (!RegExp(r'^[0-9]+$').hasMatch(cedula)) {
      return false;
    }

    // Validar región (los dos primeros dígitos)
    final digitoRegion = int.parse(cedula.substring(0, 2));
    if (digitoRegion < 1 || digitoRegion > 24) {
      return false;
    }

    // Algoritmo de validación
    final ultimoDigito = int.parse(cedula.substring(9, 10));

    // Sumar pares
    var pares = 0;
    for (var i = 1; i < 9; i += 2) {
      pares += int.parse(cedula.substring(i, i + 1));
    }

    // Procesar impares
    var impares = 0;
    for (var i = 0; i < 9; i += 2) {
      var numero = int.parse(cedula.substring(i, i + 1)) * 2;
      if (numero > 9) {
        numero -= 9;
      }
      impares += numero;
    }

    final sumaTotal = pares + impares;
    final primerDigitoSuma = sumaTotal.toString().substring(0, 1);
    final decena = (int.parse(primerDigitoSuma) + 1) * 10;
    var digitoValidador = decena - sumaTotal;

    if (digitoValidador == 10) {
      digitoValidador = 0;
    }

    return digitoValidador == ultimoDigito;
  }

  static String? validarConMensaje(String cedula) {
    if (cedula.isEmpty) {
      return 'La cédula es obligatoria';
    }
    if (cedula.length != 10) {
      return 'La cédula debe tener 10 dígitos';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(cedula)) {
      return 'La cédula solo debe contener números';
    }
    if (!validar(cedula)) {
      return 'La cédula no es válida para Ecuador';
    }
    return null;
  }
}