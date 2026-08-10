import 'package:flutter/material.dart';

import '../../data/models/cricket_models.dart';
import 'package:trace_odd/shared/theme/colors.dart';

/// Compact, sortable points table for a tournament.
///
/// Columns:  # | Team | P | W | L | T | NR | Pts | NRR
///
/// The top two rows are highlighted with a subtle accent
/// background to indicate qualifying positions.
class PointsTableWidget extends StatefulWidget {
  final List<PointsTableEntry> entries;

  const PointsTableWidget({super.key, required this.entries});

  @override
  State<PointsTableWidget> createState() => _PointsTableWidgetState();
}

class _PointsTableWidgetState extends State<PointsTableWidget> {
  int _sortColumn = 0; // default: position / points
  bool _ascending = false;

  static const _colHeaders = [
    '#',
    'Team',
    'P',
    'W',
    'L',
    'T',
    'NR',
    'Pts',
    'NRR',
  ];

  late List<PointsTableEntry> _sorted;

  @override
  void initState() {
    super.initState();
    _sorted = List.of(widget.entries);
    _sort(7, false); // default sort by points descending
  }

  @override
  void didUpdateWidget(covariant PointsTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries != widget.entries) {
      _sorted = List.of(widget.entries);
      _sort(_sortColumn, _ascending);
    }
  }

  void _sort(int col, bool asc) {
    setState(() {
      _sortColumn = col;
      _ascending = asc;

      _sorted.sort((a, b) {
        int cmp;
        switch (col) {
          case 0: // #
            cmp = a.points.compareTo(b.points);
            if (cmp == 0) cmp = a.nrr.compareTo(b.nrr);
            break;
          case 1: // Team
            cmp = a.teamName.compareTo(b.teamName);
            break;
          case 2: // P
            cmp = a.played.compareTo(b.played);
            break;
          case 3: // W
            cmp = a.won.compareTo(b.won);
            break;
          case 4: // L
            cmp = a.lost.compareTo(b.lost);
            break;
          case 5: // T
            cmp = a.tied.compareTo(b.tied);
            break;
          case 6: // NR
            cmp = a.noResult.compareTo(b.noResult);
            break;
          case 7: // Pts
            cmp = a.points.compareTo(b.points);
            if (cmp == 0) cmp = a.nrr.compareTo(b.nrr);
            break;
          case 8: // NRR
            cmp = a.nrr.compareTo(b.nrr);
            break;
          default:
            cmp = 0;
        }
        return asc ? cmp : -cmp;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_sorted.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No standings data available.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E31),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            AppColors.primaryDark.withOpacity(0.6),
          ),
          dataRowMinHeight: 40,
          dataRowMaxHeight: 44,
          headingRowHeight: 36,
          horizontalMargin: 8,
          columnSpacing: 14,
          columns: List.generate(_colHeaders.length, (i) {
            final w = i == 1 ? 120.0 : (i == 8 ? 56.0 : 36.0);
            return DataColumn(
              label: _HeaderLabel(
                text: _colHeaders[i],
                active: i == _sortColumn,
                ascending: _ascending,
              ),
              onSort: (col, asc) => _sort(col, asc),
              columnWidth: FixedColumnWidth(w),
            );
          }),
          rows: List.generate(_sorted.length, (i) {
            final e = _sorted[i];
            final isHighlight = i < 2;

            return DataRow(
              color: WidgetStateProperty.resolveWith<Color?>((states) {
                if (isHighlight) {
                  return AppColors.secondary.withOpacity(0.08);
                }
                return null;
              }),
              cells: [
                DataCell(_PosCell(rank: i + 1, highlight: isHighlight)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (e.teamLogo != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: CircleAvatar(
                            radius: 10,
                            backgroundImage: NetworkImage(e.teamLogo!),
                            backgroundColor: Colors.white12,
                          ),
                        ),
                      Flexible(
                        child: Text(
                          e.teamShortCode ?? e.teamName,
                          style: TextStyle(
                            color: isHighlight
                                ? AppColors.secondary
                                : Colors.white,
                            fontWeight: isHighlight
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(_DataText('${e.played}')),
                DataCell(_DataText('${e.won}')),
                DataCell(_DataText('${e.lost}')),
                DataCell(_DataText('${e.tied}')),
                DataCell(_DataText('${e.noResult}')),
                DataCell(_DataText(
                  '${e.points}',
                  bold: true,
                  color: isHighlight ? AppColors.secondary : null,
                )),
                DataCell(_DataText(
                  e.nrrDisplay,
                  color: e.nrr >= 0 ? AppColors.success : AppColors.error,
                )),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ── Private helpers ────────────────────────────────────────

class _HeaderLabel extends StatelessWidget {
  final String text;
  final bool active;
  final bool ascending;

  const _HeaderLabel({
    required this.text,
    required this.active,
    required this.ascending,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            color: active ? AppColors.secondary : Colors.grey,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: 11,
          ),
        ),
        if (active)
          Icon(
            ascending ? Icons.arrow_upward : Icons.arrow_downward,
            size: 12,
            color: AppColors.secondary,
          ),
      ],
    );
  }
}

class _PosCell extends StatelessWidget {
  final int rank;
  final bool highlight;

  const _PosCell({required this.rank, required this.highlight});

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (rank == 1) {
      bg = AppColors.secondary;
    } else if (rank == 2) {
      bg = AppColors.accent;
    } else {
      bg = Colors.white24;
    }

    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$rank',
        style: TextStyle(
          color: rank <= 2 ? Colors.black : Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DataText extends StatelessWidget {
  final String text;
  final bool bold;
  final Color? color;

  const _DataText(this.text, {this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? Colors.white,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }
}
