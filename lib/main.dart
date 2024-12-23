// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _DragAndDropLists(),
    );
  }
}

class ColorPalette { // defining the main colors
  static Color hoverList1Color = Colors.blue.withOpacity(0.2);
  static Color hoverList2Color = Colors.green.withOpacity(0.2);

  static Color dragItemList1Color = Colors.blue;
  static Color dragItemList2Color = Colors.green;
  static Color hoveredItemColor = Colors.grey.withOpacity(0.5);
  static Color highlightedItemColor = Colors.yellow.withOpacity(0.5);
}

class _DragAndDropLists extends StatefulWidget {
  @override
  _DragAndDropListsState createState() => _DragAndDropListsState();
}

class _DragAndDropListsState extends State<_DragAndDropLists> {
  final List<Map<String, dynamic>> list1Items = [
    {"name": "Item 1", "value1": 10, "value2": 20},
    {"name": "Item 2", "value1": 15, "value2": 30},
    {"name": "Item 3", "value1": 20, "value2": 25},
    {"name": "Item 4", "value1": 25, "value2": 35},
    {"name": "Item 5", "value1": 10, "value2": 20},
    {"name": "Item 6", "value1": 15, "value2": 30},
    {"name": "Item 7", "value1": 20, "value2": 25},
    {"name": "Item 8", "value1": 25, "value2": 35},
  ];

  final List<Map<String, dynamic>> list2Items = [];

  Map<String, dynamic>? list2HoveredItem; // item is hover when a drag is placed on it
  Map<String, dynamic>? newList2Item; // last item recent add in a list
  bool isHoveringList1 = false;
  bool isHoveringList2 = false;

  void _highlightLastNewItem(Map<String, dynamic> item) { // will highlight the new and last item added to the list
    setState(() {
      newList2Item = item;
    });
    Timer(const Duration(seconds: 3, milliseconds: 500), () { // highlight duration
      setState(() {
        if (newList2Item == item) {
          newList2Item = null;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Drag & Drop Lists Flutter"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // List 1
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      const Text("List 1", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: DragTarget<Map<String, dynamic>>(
                          onWillAccept: (data) {
                            if(!list1Items.contains(data)){
                              setState(() {
                                isHoveringList1 = true;
                              });
                            }

                            return !list1Items.contains(data);
                          },
                          onAccept: (data) {
                            setState(() {
                              list1Items.add(data);
                              list2Items.remove(data);
                              isHoveringList1 = false;
                            });
                          },
                          onLeave: (data) {
                            setState(() {
                              isHoveringList1 = false;
                            });
                          },
                          builder: (context, candidateData, rejectedData) {
                            return Container(
                              color: isHoveringList1 ? ColorPalette.hoverList1Color : Colors.transparent,
                              child: ListView.builder(
                                itemCount: list1Items.length,
                                itemBuilder: (context, index) {
                                  final item = list1Items[index];
                                  return Draggable<Map<String, dynamic>>(
                                    data: item,
                                    feedback: Material(
                                      child: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        color: ColorPalette.dragItemList1Color,
                                        child: Text(item["name"], style: const TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.5,
                                      child: ListTile(
                                        title: Text(item["name"]),
                                      ),
                                    ),
                                    child: ListTile(
                                      title: Text(item["name"]),
                                    ),
                                  );
                                },
                              )
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // List 2
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      const Text("List 2", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: DragTarget<Map<String, dynamic>>(
                          onWillAccept: (data) {
                            if(!list2Items.contains(data)){
                              setState(() {
                                isHoveringList2 = true;
                              });
                            }

                            return !list2Items.contains(data);
                          },
                          onAccept: (data) {
                            setState(() {
                              list2Items.add(data);
                              list1Items.remove(data);
                              _highlightLastNewItem(data);
                              isHoveringList2 = false;
                            });
                          },
                          onLeave: (data) {
                            setState(() {
                              isHoveringList2 = false;
                            });
                          },
                          builder: (context, candidateData, rejectedData) {
                            return Container(
                              color: isHoveringList2 ? ColorPalette.hoverList2Color : Colors.transparent,
                              child: ListView.builder(
                                itemBuilder: (context, index) {
                                  final item = list2Items[index];
                                  final isHighlighted = item == newList2Item;
                                  final itemIsHovered = item == list2HoveredItem;
                                  final isLastItem = index == list2Items.length - 1;

                                  return DragTarget<Map<String, dynamic>>(
                                    key: ValueKey(item), // Añadido: Key única
                                    onWillAccept: (data) {
                                      setState(() {
                                        list2HoveredItem = item;
                                      });
                                      return true;
                                    },
                                    onLeave: (data) {
                                      setState(() {
                                        list2HoveredItem = null;
                                      });
                                    },
                                    onAccept: (data) {
                                      setState(() {
                                        list2Items.remove(data);
                                        list2Items.insert(index, data);
                                        list1Items.remove(data);
                                        list2HoveredItem = null;
                                        _highlightLastNewItem(data);
                                      });
                                    },
                                    builder: (context, candidateData, rejectedData) {
                                      return Draggable<Map<String, dynamic>>(
                                        data: item,
                                        feedback: Material(
                                          child: Container(
                                            padding: const EdgeInsets.all(8.0),
                                            color: ColorPalette.dragItemList2Color,
                                            child: Text(item["name"], style: const TextStyle(color: Colors.white)),
                                          ),
                                        ),
                                        childWhenDragging: Opacity(
                                          opacity: 0.5,
                                          child: ListTile(
                                            title: Text(item["name"]),
                                          ),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: itemIsHovered ? ColorPalette.hoveredItemColor
                                              : isHighlighted ? ColorPalette.highlightedItemColor : Colors.transparent,
                                            border: isLastItem && itemIsHovered || isLastItem && isHoveringList2
                                                ? const Border(bottom: BorderSide(color: Colors.black, width: 2)) 
                                                : itemIsHovered 
                                                    ? const Border(top: BorderSide(color: Colors.black, width: 2))
                                                    : const Border(top: BorderSide(color: Colors.transparent, width: 0)),
                                          ),
                                          child: ListTile(
                                            title: Text(item["name"]),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                itemCount: list2Items.length,
                              )
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