import 'package:flutter/material.dart';

import '../common/common.dart';

class EmptyDataView extends StatelessWidget {
  const EmptyDataView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context)?.noData ?? ''),
    );
  }
}
