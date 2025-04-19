import 'package:flutter/material.dart';
import 'package:rent_cam/core/widget/appbar.dart';

class AddStudio extends StatelessWidget {
  const AddStudio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Add Studio',
      ),
    );
  }
}
