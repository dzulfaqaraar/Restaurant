import 'package:flutter/material.dart';

import '../common/common.dart';

class NoConnectionView extends StatelessWidget {
  const NoConnectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context)?.noConnection ?? ''),
    );
  }
}
