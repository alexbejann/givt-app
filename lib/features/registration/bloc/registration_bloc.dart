import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:givt_app/features/auth/repositories/auth_repository.dart';
import 'package:givt_app/shared/models/temp_user.dart';
import 'package:givt_app/shared/models/user_ext.dart';

part 'registration_event.dart';
part 'registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegistrationBloc(this.authRepositoy) : super(const RegistrationState()) {
    on<RegistrationPasswordSubmitted>(_onRegistrationPasswordSubmitted);

    on<RegistrationPersonalInfoSubmitted>(_onRegistrationPersonalInfoSubmitted);
  }

  final AuthRepositoy authRepositoy;

  FutureOr<void> _onRegistrationPasswordSubmitted(
    RegistrationPasswordSubmitted event,
    Emitter<RegistrationState> emit,
  ) {
    emit(state.copyWith(status: RegistrationStatus.loading));
    emit(
      state.copyWith(
        status: RegistrationStatus.personalInfo,
        email: event.email,
        firstName: event.firstName,
        lastName: event.lastName,
        password: event.password,
      ),
    );
  }

  FutureOr<void> _onRegistrationPersonalInfoSubmitted(
    RegistrationPersonalInfoSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(state.copyWith(status: RegistrationStatus.loading));
    final countryIso = await FlutterSimCountryCode.simCountryCode;

    final tempUser = TempUser(
      email: state.email,
      country: countryIso ?? 'NL',
      appLanguage: event.appLanguage,
      timeZoneId: await FlutterNativeTimezone.getLocalTimezone(),
      amountLimit: countryIso?.toUpperCase() == 'US' ? 4999 : 499,
      address: event.address,
      city: event.city,
      firstName: state.firstName,
      iban: event.iban,
      lastName: state.lastName,
      password: state.password,
      phoneNumber: event.phoneNumber,
      postalCode: event.postalCode,
      accountNumber: event.accountNumber,
      sortCode: event.sortCode,
    );

    try {
      final registeredUserExt = await authRepositoy.registerUser(
        isTempUser: false,
        tempUser: tempUser,
      );

      emit(
        state.copyWith(
          status: RegistrationStatus.mandateExplanation,
          registeredUser: registeredUserExt,
        ),
      );
    } catch (e) {
      log(e.toString());
      emit(
        state.copyWith(status: RegistrationStatus.failure),
      );
    }
  }
}
