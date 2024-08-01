import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ExpenseTile extends StatelessWidget {
  final String title;
  final String trailing;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDeletePressed;

  const ExpenseTile({
    super.key,
    required this.title,
    required this.trailing,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            backgroundColor: Colors.black12,
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            onPressed: onEditPressed,
            icon: Icons.edit,
          ),
          const SizedBox(
            width: 10.0,
          ),
          SlidableAction(
            backgroundColor: Colors.redAccent.shade200,
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            onPressed: onDeletePressed,
            icon: Icons.delete,
          ),
        ],
      ),
      child: ListTile(
        title: Text(title),
        trailing: Text(trailing),
      ),
    );
  }
}
