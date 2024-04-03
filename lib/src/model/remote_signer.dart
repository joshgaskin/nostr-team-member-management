import 'package:equatable/equatable.dart';

/// {@template remote_signer}
/// A class that represents a remote signer entities (pubkey, relays, secret).
/// {@endtemplate}
class RemoteSigner extends Equatable {
  /// The public key that the user wants to sign as. The remote signer has control of the private key that matches this public key.
  final String remotePubKey;

  /// The list of relays that the user can use to connect to the remote signer.
  final List<String> relays;

  /// A secret value
  final String? secret;

  /// The scheme annotation that the remote signer uses to communicate with the user.
  final String scheme;

  /// {@macro remote_signer}
  RemoteSigner({
    required this.remotePubKey,
    required this.relays,
    required this.scheme,
    this.secret,
  });

  factory RemoteSigner.fromRawConnectionString(String connectionString) {
    final uri = Uri.parse(connectionString);

    final maybeRelayParams = uri.queryParametersAll['relay'];

    if (maybeRelayParams == null || maybeRelayParams.isEmpty) {
      throw ArgumentError(
        'No relay provided in the connection string, please provide at least one relay.',
      );
    }

    final remotePubKey = uri.host;

    if (remotePubKey.startsWith("npub")) {
      throw ArgumentError(
        'The remote public key should be in hex format, not in npub format.',
      );
    }

    final relays = maybeRelayParams.map((e) => e.toString()).toList();
    final secret = uri.queryParameters['secret'];
    final scheme = uri.scheme;

    return RemoteSigner(
      remotePubKey: remotePubKey,
      relays: relays,
      secret: secret,
      scheme: scheme,
    );
  }

  @override
  List<Object?> get props => [
        remotePubKey,
        relays,
        secret,
      ];
}
