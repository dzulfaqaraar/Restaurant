import 'package:flutter/material.dart';

import '../common/common.dart';

class FailedDataView extends StatelessWidget {
  const FailedDataView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context)?.failedToLoad ?? ''),
    );
  }
}
