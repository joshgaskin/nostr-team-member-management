import 'package:dart_nostr/dart_nostr.dart';
import 'package:nostr_team_member_management/nostr_team_member_management.dart';

void main() async {
  final connectionString =
      'bunker://a441bc75901123b92dc3a8dc0aab1ca1d73ea3fde5017e589d3889c7559cf955?relay=wss://relay.nsec.app';

  final localeKeyPair = NostrKeyPairs.generate();

  final manager = NostrTeamManager(
    connectionString: connectionString,
    localeKeyPair: localeKeyPair,
  );

  await manager.connect();

  final eventToSign = NostrEvent(
    content: "Hello from dart_nostr package",
    createdAt: DateTime.now(),
    id: null,
    kind: 1,
    pubkey: localeKeyPair.public,
    sig: null,
    tags: [],
  );

  final requestId =
      DateTime.now().millisecondsSinceEpoch.toString() + "_Gwhyyy";

  final requestEvent = manager.requestEvent(
    id: requestId,
    eventToSign: eventToSign,
  );

  manager.sendRequestEvent(
    requestEvent,
    onOk: (relay, ok) {
      print('Event sent: $ok');
    },
  );

  final sub = manager.subscribe(requestId);

  sub.stream.listen((event) {
    print('Event received: $event');
  });
}
