class MenuReportes {
  static final List<Map<String, dynamic>> sideMenus = [
    {'title': 'Fecha', 'image': 'assets/imagenes/filtro.png'},
    {'title': 'Sucursal', 'image': 'assets/images/sucursal.png'},
    {'title': 'Pdf', 'image': 'assets/imagenes/pdf.png'},
  ];

  // Método para obtener los menús laterales
  static List<Map<String, dynamic>> getSideMenus() {
    return sideMenus;
  }
}

class Seleccion {
  static final List<Map<String, dynamic>> sideSeleccion = [
    {'title': 'Dia'},
    {'title': 'Semana'},
    {'title': 'Mes'},
    {'title': 'Dia pasado'},
    {'title': 'Semana pasada'},
    {'title': 'Mes pasado'},
  ];
  static List<Map<String, dynamic>> getsideSeleccion() {
    return sideSeleccion;
  }
}
