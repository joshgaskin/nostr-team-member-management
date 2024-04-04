import 'dart:convert';

import 'package:dart_nostr/dart_nostr.dart';
import 'package:nostr_team_member_management/nostr_team_member_management.dart';
import 'package:nostr_team_member_management/src/model/json_rpc_action.dart';
import 'package:nostr_team_member_management/src/model/remote_signer.dart';
import 'package:nostr_team_member_management/src/utils/nip04.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  final remotePubKey =
      "fa984bd7dbb282f07e16e7ae87b26a2a7b9b90b7246a44771f0cf5ae58018f52";

  final connectionString =
      'bunker://$remotePubKey?relay=wss://some-relay.com&relay=wss://someOtherRelay.com&secret=maybe-a-secret';

  test("parsing the connection String", () {
    final parsedSigner = RemoteSigner.fromRawConnectionString(
      connectionString,
    );

    expect(parsedSigner.remotePubKey, remotePubKey);
    [
      'wss://some-relay.com',
      'wss://someOtherRelay.com',
    ].forEach(
      (element) => expect(
        parsedSigner.relays,
        contains(element),
      ),
    );

    expect(parsedSigner.secret, 'maybe-a-secret');
  });

  test(
    'request event',
    () async {
      final keyPair = NostrKeyPairs.generate();

      final eventToSignRemotly = NostrEvent(
        content: "Hello World",
        createdAt: DateTime.now(),
        kind: 1,
        pubkey: keyPair.public,
        tags: [],
        id: null,
        sig: null,
      );

      final manager = NostrTeamManager(
        connectionString: connectionString,
        localeKeyPair: keyPair,
      );

      final id = DateTime.now().millisecondsSinceEpoch.toString();

      final requestEv = await manager.requestEvent(
        id: id,
        eventToSign: eventToSignRemotly,
      );

      expect(requestEv, isA<NostrEvent>());
      expect(requestEv.kind, 24133);

      final manualNip4 = Nip4.encryptContent(
        jsonEncode(
          NostrJsonRpcAction(
            id: id,
            method: "sign_event",
            params: [
              jsonEncode(eventToSignRemotly.toMap()),
            ],
          ).toMap(),
        ),
        manager.remoteSigner.remotePubKey,
        keyPair,
      );

      final decryptEventContent = Nip4.decryptContent(
        requestEv.content!,
        manager.remoteSigner.remotePubKey,
        keyPair,
      );

      final manualNip4Content = Nip4.decryptContent(
        manualNip4,
        manager.remoteSigner.remotePubKey,
        keyPair,
      );

      expect(decryptEventContent, manualNip4Content);
    },
  );
}
