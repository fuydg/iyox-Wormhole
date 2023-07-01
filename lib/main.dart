import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:iyox_wormhole/pages/basePage.dart';
import 'package:flutter/services.dart';

void main()
{
  runApp(const WormholeApp());
}

class WormholeApp extends StatelessWidget {
  const WormholeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Wormhole',
        theme: ThemeData(
          colorScheme: lightColorScheme,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme,
          useMaterial3: true,
        ),
        themeMode: ThemeMode.dark,
        home: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: const BasePage(),
        ),
      );
    });
  }
}
