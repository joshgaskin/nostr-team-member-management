import 'package:equatable/equatable.dart';

/// {@template nostr_json_rpc_action}
/// A class that represents a Nostr JSON RPC action, used in a remote signer event request.
/// {@endtemplate}
class NostrJsonRpcAction extends Equatable {
  /// A random id for the request.
  final String id;

  /// The method to be called.
  final String method;

  /// The parameters for the method.
  final List<String> params;

  /// {@macro nostr_json_rpc_action}
  NostrJsonRpcAction({
    required this.id,
    required this.method,
    required this.params,
  });

  @override
  List<Object?> get props => [id, method, params];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'method': method,
      'params': params,
    };
  }
}
