import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:givt_app/core/enums/enums.dart';

mixin CountryIsoInfo {
  Future<String> get checkCountryIso;

  String get countryIso;

  bool get isUS;
}

class CountryIsoInfoImpl implements CountryIsoInfo {
  CountryIsoInfoImpl();

  String _countryIso = Country.nl.countryCode;

  @override
  Future<String> get checkCountryIso async {
    try {
      _countryIso =
          await FlutterSimCountryCode.simCountryCode ?? Country.nl.countryCode;
    } on PlatformException catch (e) {
      log(e.toString());
    }
    return _countryIso;
  }

  @override
  String get countryIso => _countryIso;

  @override
  bool get isUS => _countryIso == Country.us.countryCode;
}
