import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../../domain/models/dns_test_result.dart';
import 'dns_probe_result.dart';

Future<DnsProbeResult> probeDns(
  String server, {
  String domain = 'example.com',
  Duration timeout = const Duration(seconds: 2),
  bool ipv6 = false,
}) async {
  RawDatagramSocket? socket;
  StreamSubscription<RawSocketEvent>? subscription;

  try {
    final address = InternetAddress.tryParse(server);
    final expectedType = ipv6 ? InternetAddressType.IPv6 : InternetAddressType.IPv4;
    if (address == null || address.type != expectedType) {
      return DnsProbeResult(
        status: DnsTestStatus.failed,
        error: ipv6 ? 'Invalid IPv6 address' : 'Invalid IPv4 address',
      );
    }

    socket = await RawDatagramSocket.bind(
      ipv6 ? InternetAddress.anyIPv6 : InternetAddress.anyIPv4,
      0,
    );
    socket.readEventsEnabled = true;

    final transactionId = Random().nextInt(65536);
    final query = _buildQuery(transactionId, domain, ipv6 ? 0x001C : 0x0001);

    final sent = socket.send(query, address, 53);
    if (sent <= 0) {
      return const DnsProbeResult(
        status: DnsTestStatus.failed,
        error: 'UDP send failed',
      );
    }

    final completer = Completer<DnsProbeResult>();
    final stopwatch = Stopwatch()..start();

    subscription = socket.listen(
      (event) {
        if (event != RawSocketEvent.read) return;

        final datagram = socket?.receive();
        if (datagram == null || datagram.data.length < 12) return;

        final data = datagram.data;
        final responseId = (data[0] << 8) | data[1];
        final flags = (data[2] << 8) | data[3];

        if (responseId != transactionId) return;

        stopwatch.stop();

        final isResponse = (flags & 0x8000) != 0;
        final rcode = flags & 0x000F;

        if (!isResponse || rcode != 0) {
          if (!completer.isCompleted) {
            completer.complete(
              DnsProbeResult(
                status: DnsTestStatus.failed,
                error: 'DNS response error: $rcode',
              ),
            );
          }
          return;
        }

        if (!completer.isCompleted) {
          completer.complete(
            DnsProbeResult(
              status: DnsTestStatus.success,
              latencyMs: stopwatch.elapsedMilliseconds,
            ),
          );
        }
      },
      onError: (_) {
        if (!completer.isCompleted) {
          completer.complete(
            const DnsProbeResult(
              status: DnsTestStatus.failed,
              error: 'Socket error',
            ),
          );
        }
      },
    );

    Future<void>.delayed(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(
          const DnsProbeResult(
            status: DnsTestStatus.timeout,
            error: 'DNS request timed out',
          ),
        );
      }
    });

    return await completer.future;
  } on SocketException catch (e) {
    return DnsProbeResult(
      status: DnsTestStatus.failed,
      error: e.message,
    );
  } on UnsupportedError catch (e) {
    return DnsProbeResult(
      status: DnsTestStatus.unsupported,
      error: e.message,
    );
  } catch (e) {
    return DnsProbeResult(
      status: DnsTestStatus.failed,
      error: e.toString(),
    );
  } finally {
    await subscription?.cancel();
    socket?.close();
  }
}

List<int> _buildQuery(int id, String domain, int qtype) {
  final bytes = <int>[
    (id >> 8) & 0xFF,
    id & 0xFF,
    0x01,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
  ];

  for (final label in domain.split('.')) {
    final encoded = utf8.encode(label);
    bytes.add(encoded.length);
    bytes.addAll(encoded);
  }

  bytes.add(0x00);
  bytes.add((qtype >> 8) & 0xFF);
  bytes.add(qtype & 0xFF); // A or AAAA
  bytes.addAll(const [0x00, 0x01]); // IN

  return bytes;
}
