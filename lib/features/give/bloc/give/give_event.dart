part of 'give_bloc.dart';

abstract class GiveEvent extends Equatable {
  const GiveEvent();

  @override
  List<Object> get props => [];
}

class GiveQRCodeScanned extends GiveEvent {
  const GiveQRCodeScanned(this.rawValue, this.userGUID);

  final String rawValue;
  final String userGUID;

  @override
  List<Object> get props => [rawValue, userGUID];
}

class GiveOrganisationSelected extends GiveEvent {
  const GiveOrganisationSelected(this.nameSpace, this.userGUID);

  final String nameSpace;
  final String userGUID;

  @override
  List<Object> get props => [nameSpace, userGUID];
}

class GiveAmountChanged extends GiveEvent {
  const GiveAmountChanged({
    required this.firstCollectionAmount,
    required this.secondCollectionAmount,
    required this.thirdCollectionAmount,
  });

  final double firstCollectionAmount;
  final double secondCollectionAmount;
  final double thirdCollectionAmount;

  @override
  List<Object> get props => [
        firstCollectionAmount,
        secondCollectionAmount,
        thirdCollectionAmount,
      ];
}
