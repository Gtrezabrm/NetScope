# NetScope 🌐

**Android network & DNS diagnostics for real-world connectivity.**

NetScope is an open-source Android-first diagnostic app designed to help users understand the quality, stability, and accessibility of their current internet connection — with particular attention to real-world conditions and gaming connectivity.

> Built by **Gtrezabrm** with a focus on honest measurements, clear explanations, and no fake "game ping" claims.

## ✨ What NetScope does

### 🧪 DNS Benchmark
- Sends real DNS queries directly to the selected resolver.
- Measures query latency, median, jitter, minimum/maximum latency, packet loss, and reliability.
- Uses multiple domains to reduce the chance that one cached or unusual response dominates the result.
- Ranks resolvers using both speed **and** reliability.
- Separates unstable/unreachable resolvers from reliable recommendations.
- Supports custom DNS servers and IPv6 DNS where available.

### 📶 Network Diagnostics
- Shows the current connection state and transport type.
- Displays available IPv4, IPv6, and system DNS information.
- Helps distinguish DNS problems from broader connectivity problems.
- Provides additional DoH and DoT/TLS reachability checks.

### 🎮 Gaming Connectivity
NetScope does **not** pretend that a TCP connection to an arbitrary host is the same thing as in-game latency.

Instead, Gaming Diagnostics provides transparent TCP connectivity/path checks with:
- Latency
- Jitter
- Connection loss
- Custom host/IP and port testing
- Useful public connectivity targets such as Steam and Epic Games

Results are reported as connectivity observations, not guaranteed game-server ping.

### 📊 Results & History
- Detailed per-DNS results
- Per-request measurement details
- Compare multiple DNS resolvers
- Copy DNS addresses and complete reports
- Keep local test history and review previous results

## 🎯 Why NetScope exists

Internet quality is not defined by a single ping number. A resolver can look extremely fast while dropping a large percentage of requests. A network can have a fast DNS response while suffering from high jitter or unstable TCP connectivity.

NetScope is built around a simple idea:

**Measure what actually happened, explain what the measurement means, and avoid claiming more than the test can prove.**

## 🔬 Measurement philosophy

NetScope tries to make its measurements understandable and reproducible:

- **DNS latency** = time between sending a DNS query and receiving the matching DNS response.
- **Packet loss** = proportion of DNS attempts that did not receive a valid response within the test timeout.
- **Jitter** = variation of successful DNS response times around their average.
- **TCP latency** = time required to establish the tested TCP connection to the selected destination and port.
- **Timeout is not automatically reported as "closed".** A timeout may also indicate filtering, routing problems, or an unreachable destination.

The app does not use a third-party server to invent DNS latency values.

## 🔐 Privacy & security

NetScope is designed as a local diagnostic tool.

- No account is required.
- No API key is required for the core tests.
- Test history is stored locally on the device.
- The app uses only the Android network permissions needed for diagnostics.
- It does not include a DNS-changing/VPN feature.
- It does not claim to bypass network restrictions.

## 🧩 Technology

- Flutter / Dart
- Android-first architecture
- Native Android network information through a platform channel
- Direct UDP DNS probing on supported platforms
- TCP connectivity diagnostics
- Shared local preferences for settings and history
- Persian RTL interface with Vazirmatn and Lalezar typography

## ⚠️ Important limitations

NetScope is a diagnostic tool, not a guarantee of application or game performance.

A successful connection to a public host does not prove that every service, CDN, game server, or route is reachable. Likewise, a failed test to one destination does not prove that the entire service is blocked.

Gaming results should therefore be interpreted as **network connectivity indicators**, not guaranteed in-game ping or matchmaking availability.

## 🚀 Status

**Version:** `1.0.0`

NetScope is currently being released as an early public version. Real-world testing across different networks is encouraged before treating measurements as universal conclusions.

## 🤝 Contributing

Issues, testing feedback, bug reports, and improvements are welcome. If you find a misleading result or a measurement that does not behave as expected, please include the test conditions and relevant diagnostic details when possible.

## 📄 License

This project is intended to be open source. See `LICENSE` for the applicable license terms.
