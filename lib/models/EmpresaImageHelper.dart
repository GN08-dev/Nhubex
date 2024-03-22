class EmpresaImageHelper {
  static Map<String, String> empresaSiglas = {
    'pe': 'Poly Electric',
    've': 'Veana',
  };

  static String getImageUrl(String empresa) {
    switch (empresa.toLowerCase()) {
      case 'pe':
        return 'https://macuna.tecfinanzas.com/Imagenes/PE//Logo.png';
      case 've':
        return 'https://macuna.tecfinanzas.com/Imagenes/VE//encabezado1.png';
      default:
        return 'https://macuna.tecfinanzas.com/Imagenes/Logo_Nhubex.png';
    }
  }

  static String getCompanyName(String empresa) {
    return empresaSiglas[empresa.toLowerCase()] ??
        'Nombre de la Empresa Desconocido';
  }
}
