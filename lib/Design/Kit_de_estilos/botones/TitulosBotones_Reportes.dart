class ButtonDataProvider {
  static final List<Map<String, dynamic>> inventoryButtons = [
    {'title': 'Inventario de Extracto costo Almacen', 'info': 'sin info'},
    {'title': 'Inventario de referencia', 'info': 'sin info'},
    {'title': 'Inventario negativo', 'info': 'sin info'},
  ];
  static List<Map<String, dynamic>> getInventoryButtons() {
    return inventoryButtons;
  }

  static final List<Map<String, dynamic>> monitoringButtons = [
    {'title': 'Monitoreo de almacen', 'info': 'sin info'},
    {'title': 'Monitoreo de clientes', 'info': 'sin info'},
    {'title': 'Monitoreo de Usuario', 'info': 'sin info'},
  ];
  static List<Map<String, dynamic>> getMonitoringButtons() {
    return monitoringButtons;
  }

  static final List<Map<String, dynamic>> salesButtons = [
    // {'title': 'Ventas del diario', 'info': 'sin info'},
    /* {
      'title': 'Venta por Ticket',
      'info': 'sin info'
    }, //rep_venta_ticket_consolidado
  */
    {
      'title': 'Venta por Forma de Pago',
      'info': 'sin info'
    }, //rep_venta_consolidada_forma_pago
    /*{
    //  'title': 'Venta por Ticket',
    //  'info': 'sin info'
   },*/ //rep_venta_ticket_detalle
    {
      'title': 'Venta por Sucursal',
      'info': 'sin info'
    }, //rep_venta_sucursal_detalle
    /* {
      'title': 'Venta por Forma de Pago',
      'info': 'sin info'
    }, //rep_venta_detalle_forma_pago*/
    {
      'title': 'Venta Consolidada por Rango de Fechas',
      'info': 'sin info'
    }, //rep_venta_consolidada
  ];
  static List<Map<String, dynamic>> getSalesButtons() {
    return salesButtons;
  }

  static final List<Map<String, dynamic>> otherButtons = [
    {'title': 'Consulta de producto', 'info': 'sin info'},
    {'title': 'Consulta de productos (cámara)', 'info': 'sin info'},
  ];
  static List<Map<String, dynamic>> getOtherButtons() {
    return otherButtons;
  }
}
