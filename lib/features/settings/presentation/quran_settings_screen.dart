import 'package:flutter/material.dart';
import '../domain/entities/quran_setting.dart';
import '../domain/settings_manager.dart';
import 'widgets/settings_row_widget.dart';

class QuranSettingsScreen extends StatefulWidget {
  const QuranSettingsScreen({Key? key}) : super(key: key);

  @override
  State<QuranSettingsScreen> createState() => _QuranSettingsScreenState();
}

class _QuranSettingsScreenState extends State<QuranSettingsScreen> {
  final List<QuranSetting> _settings =
      QuranSettingsManager.instance.generateSettings();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text("Settings")),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: ListView.builder(
            itemBuilder: (
              context,
              index,
            ) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: IntrinsicHeight(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: QuranSettingsRowWidget(setting: _settings[index]),
                  ),
                ),
              );
            },
            itemCount: _settings.length,
          ),
        ),
      ),
    );
  }
}
