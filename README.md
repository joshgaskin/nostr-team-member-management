# Usage

## Initiating a connection

### From a connection string

using a connection string (eg. `bunker://...`), you can verify and initiaite a new connection to the remote signer relays like so:

```dart
/// Your remote signer connection string
final connectionString = "bunker://<remote-pubkey>?relay=<wss://relay-to-connect-on>&relay=<wss://another-relay-to-connect-on>&secret=<optional-secret-value>";

/// The new generated user local key pair to be used to reference the user in remote signer requests.
final localeKeyPair = NostrKeyPairs.generate();

/// The manager instance
final manager = NostrTeamManager(
  connectionString: connectionString,
  localeKeyPair: localeKeyPair,
);

/// Connects to the remote signer relays.
await manager.connect();
```

### From Nip 05

// TODO

## Create a new signature request

```dart
/// The event template to be signed remotely, notice that the `sig` field is null.
final eventToSignRemotly = NostrEvent(
  content: "Hello from dart_nostr package",
  createdAt: DateTime.now(),
  kind: 1,
  pubkey: localeKeyPair.public,
  tags: [],
  sig: null,
  id: null,
);

/// The request id to which the remote signer will respond to.
final requestId = "${DateTime.now().millisecondsSinceEpoch}_Gwhyyy";

/// The request event that will be sent to the remote signer.
final requestEvent = manager.requestEvent(
   id: requestId,
   eventToSign: eventToSign,
 );


/// Send the request event to the remote signer relays.
 manager.sendRequestEvent(
    requestEvent,
    onOk: (relay, ok) {
      print('Event sent: $ok');
    },
  );
```
