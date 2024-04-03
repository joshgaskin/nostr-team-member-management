import 'package:nostr_team_member_management/src/model/remote_signer.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test("parsing the connection String", () {
    final connectionString =
        'bunker://something?relay=wss://some-relay.com&relay=wss://someOtherRelay.com&secret=maybe-a-secret';

    final parsedSigner = RemoteSigner.fromRawConnectionString(
      connectionString,
    );

    expect(parsedSigner.remotePubKey, 'something');
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
}
