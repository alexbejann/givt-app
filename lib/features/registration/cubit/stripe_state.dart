part of 'stripe_cubit.dart';

enum StripeObjectStatus {
  initial,
  loading,
  display,
  success,
  failure,
}

class StripeState extends Equatable {
  const StripeState({
    this.stripeStatus = StripeObjectStatus.initial,
    this.stripeObject =
        const StripeResponse(url: '', successUrl: '', cancelUrl: ''),
  });
  final StripeObjectStatus stripeStatus;
  final StripeResponse stripeObject;

  @override
  List<Object> get props => [stripeStatus, stripeObject];
  StripeState copyWith({
    StripeObjectStatus? stripeStatus,
    StripeResponse? stripeObject,
  }) {
    return StripeState(
      stripeStatus: stripeStatus ?? this.stripeStatus,
      stripeObject: stripeObject ?? this.stripeObject,
    );
  }
}

class StripeInitial extends StripeState {}
