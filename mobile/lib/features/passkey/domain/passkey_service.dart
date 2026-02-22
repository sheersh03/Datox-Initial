import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';

import '../data/passkey_repository.dart';

class PasskeyService {
  PasskeyService({PasskeyAuthenticator? authenticator})
      : _authenticator = authenticator ?? PasskeyAuthenticator();

  final PasskeyAuthenticator _authenticator;

  Future<void> registerPasskey({String? userName}) async {
    final optionsRes = await PasskeyRepository.startRegistration(userName: userName);
    final optionsMap = optionsRes['options'] as Map<String, dynamic>;
    final request = RegisterRequestType.fromJson(optionsMap);

    final platformResponse = await _authenticator.register(request);

    final credential = platformResponse.toJson();
    await PasskeyRepository.finishRegistration(credential);
  }
}
