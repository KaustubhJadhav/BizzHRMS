import 'package:flutter/material.dart';

class DataTableWidget<T> extends StatelessWidget {
  final List<String> columns;
  final List<T> data;
  final Widget Function(T item, int index) buildRow;
  final bool isLoading;
  final String? emptyMessage;

  const DataTableWidget({
    super.key,
    required this.columns,
    required this.data,
    required this.buildRow,
    this.isLoading = false,
    this.emptyMessage = 'No data available',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (data.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  emptyMessage!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns:
                    columns.map((col) => DataColumn(label: Text(col))).toList(),
                rows: List.generate(
                  data.length,
                  (index) {
                    final rowWidget = buildRow(data[index], index);
                    // Extract widgets from Row
                    final cells = rowWidget is Row
                        ? rowWidget.children.map((w) => DataCell(w)).toList()
                        : [DataCell(rowWidget)];
                    return DataRow(cells: cells);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Removed extension - not needed for current implementation
