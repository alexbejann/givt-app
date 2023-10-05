part of 'personal_summary_bloc.dart';

enum PersonalSummaryStatus {
  initial,
  loading,
  success,
  error,
  noInternet,
}

class PersonalSummaryState extends Equatable {
  const PersonalSummaryState({
    this.dateTime = '',
    this.status = PersonalSummaryStatus.initial,
    this.loggedInUserExt = const UserExt.empty(),
    this.error = '',
    this.monthlyGivts = const [],
    this.externalDonations = const [],
  });
  final PersonalSummaryStatus status;
  final UserExt loggedInUserExt;
  final String error;
  final String dateTime;
  final List<MonthlySummaryItem> monthlyGivts;
  final List<ExternalDonation> externalDonations;

  PersonalSummaryState copyWith({
    PersonalSummaryStatus? status,
    UserExt? loggedInUserExt,
    String? error,
    String? dateTime,
    List<MonthlySummaryItem>? monthlyGivts,
    List<ExternalDonation>? externalDonations,
  }) {
    return PersonalSummaryState(
      status: status ?? this.status,
      loggedInUserExt: loggedInUserExt ?? this.loggedInUserExt,
      error: error ?? this.error,
      dateTime: dateTime ?? this.dateTime,
      monthlyGivts: monthlyGivts ?? this.monthlyGivts,
      externalDonations: externalDonations ?? this.externalDonations,
    );
  }

  @override
  List<Object> get props => [
        status,
        loggedInUserExt,
        error,
        dateTime,
        monthlyGivts,
        externalDonations,
      ];
}