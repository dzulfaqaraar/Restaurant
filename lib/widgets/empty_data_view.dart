import 'package:flutter/material.dart';

import '../common/common.dart';
import '../l10n/app_localizations.dart';

class EmptyDataView extends StatelessWidget {
  const EmptyDataView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context)?.noData ?? ''),
    );
  }
}
