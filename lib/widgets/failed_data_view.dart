import 'package:flutter/material.dart';

import '../common/common.dart';
import '../l10n/app_localizations.dart';

class FailedDataView extends StatelessWidget {
  const FailedDataView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context)?.failedToLoad ?? ''),
    );
  }
}
