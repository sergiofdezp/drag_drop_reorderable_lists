import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DragAndDropPage(),
    );
  }
}

class DragAndDropPage extends StatefulWidget {
  @override
  _DragAndDropPageState createState() => _DragAndDropPageState();
}

class _DragAndDropPageState extends State<DragAndDropPage> {
  // Lista de elementos originales
  final List<Map<String, dynamic>> items = [
    {"nombre": "Tirafondos 3,9x6,5", "valor1": 10, "valor2": 20},
    {"nombre": "Tornillo roscam. 3,0x20", "valor1": 15, "valor2": 30},
    {"nombre": "Tornillo M4x8", "valor1": 20, "valor2": 25},
    {"nombre": "Junta estanqueidad EPDM", "valor1": 25, "valor2": 35},
  ];

  // Lista para los elementos seleccionados
  final List<Map<String, dynamic>> selectedItems = [];

  // Calcular sumas de columnas numéricas
  int get totalValor1 => selectedItems.fold(0, (sum, item) => sum + (item["valor1"] as int));
  int get totalValor2 => selectedItems.fold(0, (sum, item) => sum + (item["valor2"] as int));

  Map<String, dynamic>? hoveredItem;
  Map<String, dynamic>? highlightedItem;

  void _highlightItem(Map<String, dynamic> item) {
    setState(() {
      highlightedItem = item;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        highlightedItem = null;
      });
    });
  }

  void _moveItemInList(int oldIndex, int newIndex, List<Map<String, dynamic>> list) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Drag & Drop en Flutter"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Lista original
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      const Text("Lista original", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: DragTarget<Map<String, dynamic>>(
                          onWillAccept: (data) => !items.contains(data),
                          onAccept: (data) {
                            setState(() {
                              items.add(data);
                              selectedItems.remove(data);
                            });
                          },
                          builder: (context, candidateData, rejectedData) {
                            return ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return Draggable<Map<String, dynamic>>(
                                  data: item,
                                  feedback: Material(
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      color: Colors.blue,
                                      child: Text(item["nombre"], style: const TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.5,
                                    child: ListTile(
                                      title: Text(item["nombre"]),
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Text(item["nombre"]),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Nueva lista con área de drop extendida
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      const Text("Nueva lista", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: DragTarget<Map<String, dynamic>>(
                          onWillAccept: (data) => !selectedItems.contains(data),
                          onAccept: (data) {
                            setState(() {
                              selectedItems.add(data);
                              items.remove(data);
                              _highlightItem(data);
                            });
                          },
                          builder: (context, candidateData, rejectedData) {
                            return ReorderableListView.builder(
                              onReorder: (oldIndex, newIndex) => _moveItemInList(oldIndex, newIndex, selectedItems),
                              itemBuilder: (context, index) {
                                final item = selectedItems[index];
                                final isHighlighted = item == highlightedItem;
                                final isHovered = item == hoveredItem;
                                return DragTarget<Map<String, dynamic>>(
                                  key: ValueKey(item), // Añadido: Key única
                                  onWillAccept: (data) {
                                    setState(() {
                                      hoveredItem = item;
                                    });
                                    return true;
                                  },
                                  onLeave: (data) {
                                    setState(() {
                                      hoveredItem = null;
                                    });
                                  },
                                  onAccept: (data) {
                                    setState(() {
                                      selectedItems.remove(data);
                                      selectedItems.insert(index, data);
                                      items.remove(data);
                                      hoveredItem = null;
                                      _highlightItem(data);
                                    });
                                  },
                                  builder: (context, candidateData, rejectedData) {
                                    return Draggable<Map<String, dynamic>>(
                                      data: item,
                                      feedback: Material(
                                        child: Container(
                                          padding: const EdgeInsets.all(8.0),
                                          color: Colors.green,
                                          child: Text(item["nombre"], style: const TextStyle(color: Colors.white)),
                                        ),
                                      ),
                                      childWhenDragging: Opacity(
                                        opacity: 0.5,
                                        child: ListTile(
                                          title: Text(item["nombre"]),
                                        ),
                                      ),
                                      child: Container(
                                        color: isHighlighted ? Colors.yellow.withOpacity(0.5) : isHovered ? Colors.grey.withOpacity(0.5) : Colors.transparent,
                                        child: ListTile(
                                          title: Text(item["nombre"]),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              itemCount: selectedItems.length,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}