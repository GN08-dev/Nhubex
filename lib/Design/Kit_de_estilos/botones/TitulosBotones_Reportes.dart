class ButtonDataProvider {
  static final List<Map<String, dynamic>> inventoryButtons = [
    {
      'title': 'Inventario de Extracto costo Almacen',
    },
    {
      'title': 'Inventario de referencia',
    },
    {
      'title': 'Inventario negativo',
    },
  ];
  static List<Map<String, dynamic>> getInventoryButtons() {
    return inventoryButtons;
  }

  static final List<Map<String, dynamic>> monitoringButtons = [
    {
      'title': 'Monitoreo de almacen',
    },
    {
      'title': 'Monitoreo de clientes',
    },
    {
      'title': 'Monitoreo de Usuario',
    },
  ];
  static List<Map<String, dynamic>> getMonitoringButtons() {
    return monitoringButtons;
  }

  static final List<Map<String, dynamic>> salesButtons = [
    {'title': 'Venta por Forma de Pago'},
    {'title': 'Venta por Sucursal'}, //rep_venta_sucursal_detalle
    {'title': 'Venta Consolidada por Rango de Fechas'}, //rep_venta_consolidada
  ];
  static List<Map<String, dynamic>> getSalesButtons() {
    return salesButtons;
  }

  static final List<Map<String, dynamic>> otherButtons = [
    {'title': 'Consulta de producto'},
    {'title': 'Consulta de productos (cámara)'},
  ];
  static List<Map<String, dynamic>> getOtherButtons() {
    return otherButtons;
  }
}
