fvm use 3.19.5 && fvm global 3.19.5 \
  && flutter clean && flutter pub get \
  && cd example && fvm use 3.19.5 && fvm global 3.19.5 \
  && flutter clean && flutter pub get
