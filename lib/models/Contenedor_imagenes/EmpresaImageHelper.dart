class EmpresaImageHelper {
  static Map<String, String> empresaSiglas = {
    'pe': 'POLY ELECTRIC',
    've': 'VEANA',
    'gtrfo': 'GTRIUNFO',
    'nieto': 'NIETO',
    'pavel': 'PAVEL',
    'shyla': 'SHYLA',
    'pbd5': 'PBD5',
    'ctn': 'CONTINIO'
  };

  static String getImageUrl(String empresa) {
    String empresaLowerCase = empresa.toLowerCase();
    if (empresaLowerCase == 'pe') {
      return 'https://macuna.tecfinanzas.com/Imagenes/PE/Logo.png';
    } else if (empresaLowerCase == 've') {
      return 'https://macuna.tecfinanzas.com/Imagenes/VE/encabezado1.png';
    } else if (empresaLowerCase == 'gtrfo') {
      return 'https://macuna.tecfinanzas.com/Imagenes/GTRFO/Logo2.png';
    } else if (empresaLowerCase == 'nieto') {
      return 'https://macuna.tecfinanzas.com/Imagenes/NIETO/Logoxxx.png';
    } else if (empresaLowerCase == 'pavel') {
      return 'https://macuna.tecfinanzas.com/Imagenes/PAVEL/Logo.png';
    } else if (empresaLowerCase == 'shyla') {
      return 'https://macuna.tecfinanzas.com/Imagenes/shyla/Logo-126.png';
    } else if (empresaLowerCase == 'pbd5') {
      return 'https://macuna.tecfinanzas.com/Imagenes/PBD5/Logo.png';
    } else if (empresaLowerCase == 'ctn') {
      return 'https://macuna.tecfinanzas.com/Imagenes/CTN/Logo.png';
    } else {
      return 'https://macuna.tecfinanzas.com/Imagenes/Logo_Nhubex.png';
    }
  }

  static String getCompanyName(String empresa) {
    String empresaLowerCase = empresa.toLowerCase();
    return empresaSiglas[empresaLowerCase] ??
        'Nombre de la Empresa Desconocido';
  }
}
