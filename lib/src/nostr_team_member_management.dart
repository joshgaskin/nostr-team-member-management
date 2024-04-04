import 'dart:convert';

import 'package:dart_nostr/dart_nostr.dart';
import 'package:nostr_team_member_management/src/model/json_rpc_action.dart';
import 'package:nostr_team_member_management/src/model/remote_signer.dart';
import 'package:nostr_team_member_management/src/utils/nip04.dart';
import 'package:nostr_team_member_management/src/utils/utils.dart';

class NostrTeamManager {
  final String connectionString;

  RemoteSigner? _remoteSigner;
  final client = Nostr();

  RemoteSigner get remoteSigner {
    if (_remoteSigner == null) {
      throw Exception('Remote signer not initialized');
    }

    return _remoteSigner!;
  }

  NostrTeamManager({
    required this.connectionString,
  }) {
    final isValid = NostrTeamUtils.isValidUriFormat(connectionString);

    if (!isValid) {
      throw Exception('Invalid connection string');
    }

    _remoteSigner = RemoteSigner.fromRawConnectionString(
      connectionString,
    );
  }

  Future<NostrEvent> requestEvent({
    required String id,
    required NostrEvent eventToSign,
    required NostrKeyPairs localeKeyPair,
  }) async {
    final eventToSignAsMap = eventToSign.toMap();

    final jsonRpcAction = NostrJsonRpcAction(
      id: id,
      method: "sign_event",
      params: [
        jsonEncode(eventToSignAsMap),
      ],
    );

    final content = Nip4.encryptContent(
      jsonEncode(jsonRpcAction.toMap()),
      remoteSigner.remotePubKey,
      localeKeyPair,
    );

    final requestEvent = NostrEvent(
      id: null,
      sig: null,
      createdAt: DateTime.now(),
      kind: 24133,
      pubkey: localeKeyPair.public,
      tags: [
        ["p", remoteSigner.remotePubKey]
      ],
      content: content,
    );

    return requestEvent;
  }

  Future<void> connect() async {
    return client.relaysService.init(
      relaysUrl: remoteSigner.relays,
    );
  }
}
