import 'dart:convert';

import 'package:dart_nostr/dart_nostr.dart';
import 'package:dart_nostr/nostr/model/ok.dart';
import 'package:nostr_team_member_management/src/model/json_rpc_action.dart';
import 'package:nostr_team_member_management/src/model/remote_signer.dart';
import 'package:nostr_team_member_management/src/utils/nip04.dart';
import 'package:nostr_team_member_management/src/utils/utils.dart';

class NostrTeamManager {
  final String connectionString;
  final NostrKeyPairs localeKeyPair;

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
    required this.localeKeyPair,
  }) {
    final isValid = NostrTeamUtils.isValidUriFormat(connectionString);

    if (!isValid) {
      throw Exception('Invalid connection string');
    }

    _remoteSigner = RemoteSigner.fromRawConnectionString(
      connectionString,
    );
  }

  NostrEvent requestEvent({
    required String id,
    required NostrEvent eventToSign,
  }) {
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

    final date = DateTime.now();

    final tags = [
      ["p", remoteSigner.remotePubKey]
    ];

    final kind = 24133;

    final evId = NostrEvent.getEventId(
      kind: kind,
      content: content,
      createdAt: date,
      tags: tags,
      pubkey: localeKeyPair.public,
    );

    final requestEvent = NostrEvent(
      id: evId,
      sig: localeKeyPair.sign(evId),
      createdAt: date,
      kind: kind,
      pubkey: localeKeyPair.public,
      tags: tags,
      content: content,
    );

    return requestEvent;
  }

  Future<void> connect() async {
    return client.relaysService.init(
      relaysUrl: remoteSigner.relays,
    );
  }

  bool sendRequestEvent(
    NostrEvent requestEvent, {
    Function(String relay, NostrEventOkCommand ok)? onOk,
  }) {
    if (requestEvent.kind != 24133) {
      throw Exception('Invalid kind for request event, check NIP 46');
    }

    client.relaysService.sendEventToRelays(requestEvent, onOk: (relay, ok) {
      if (onOk != null) {
        onOk(relay, ok);
        return;
      }

      print('Relay: $relay, Ok: $ok');
    });

    return true;
  }

  NostrEventsStream subscribe(String id) {
    final filter = NostrFilter(
      kinds: [24133],
    );

    final sub = client.relaysService.startEventsSubscription(
      request: NostrRequest(
        filters: [
          filter,
        ],
        subscriptionId: id,
      ),
    );

    return sub;
  }
}
