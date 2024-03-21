// Clase EmpresaImageHelper
class EmpresaImageHelper {
  static Map<String, String> empresaSiglas = {
    'pe': 'Poly Electric',
    've': 'Veana',
    // Agrega más empresas según sea necesario
  };

  static String getImageUrl(String empresa) {
    // Mapea las siglas de la empresa a la URL de la imagen correspondiente
    switch (empresa.toLowerCase()) {
      case 'pe':
        return 'https://macuna.tecfinanzas.com/Imagenes/PE//Logo.png';
      case 've':
        return 'https://macuna.tecfinanzas.com/Imagenes/VE//encabezado1.png';
      // Agrega más casos según sea necesario
      default:
        // Devuelve una URL de imagen predeterminada si no se encuentra una coincidencia
        return 'https://macuna.tecfinanzas.com/Imagenes/Logo_Nhubex.png';
    }
  }

  // Método para obtener el nombre de la empresa según la sigla
  static String getCompanyName(String empresa) {
    return empresaSiglas[empresa.toLowerCase()] ??
        'Nombre de la Empresa Desconocido';
  }
}
