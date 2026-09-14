# 🌐 NetScope

> **Android-first DNS & network diagnostics — built to measure, not guess.**

[![Flutter](https://img.shields.io/badge/Flutter-Android--first-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](#)
[![License](https://img.shields.io/badge/license-open--source-green)](#license)

## 💡 Why NetScope?

When an internet connection feels slow or unstable, DNS is often the first thing people change. But without measurement, it is difficult to know whether DNS is actually the problem.

**NetScope was created to replace guesswork with measurements.**

It focuses on the user’s current connection and reports what the app can actually measure. It does not pretend that a DNS response time is the same thing as an in-game ping, and it does not label a random TCP endpoint as a game server.

## ✨ What it can do

### 🌐 DNS Benchmark

- Direct DNS queries to selected resolvers over UDP/53
- Real DNS response latency measurements
- Average, median, minimum and maximum latency
- Jitter, success rate and packet-loss-style failure rate
- Primary/secondary fallback tracking
- Reliability-aware scoring and ranking
- Best DNS recommendation for the current connection

### ⚡ Quick Test

Run a short DNS check when you want an answer quickly instead of a full benchmark.

### 📡 Network Snapshot

Inspect the connection information Android exposes to the app, including:

- Online/offline state
- Transport type
- Internet validation
- IPv4 and IPv6 information
- Current DNS information

### 🎮 Gaming & TCP Connectivity

NetScope deliberately avoids calling TCP latency to a public endpoint **“in-game ping.”**

The Gaming section checks TCP connectivity to selected public service endpoints, including **Steam** and **Epic Games**, and also lets the user enter a custom host/IP and port.

Results are interpreted carefully:

- 🟢 **Open** — the TCP connection was accepted.
- 🔴 **Rejected / closed** — the destination explicitly rejected the connection.
- 🟡 **No response / filtered** — no reliable response arrived within the test window.
- ⚪ **Connection error** — another connection error occurred.

> ⚠️ A timeout alone does **not** prove that a port is closed.

### 🧠 Network Health

A simple summary of the measured connection quality, so users can understand the result without digging through every technical value.

### 🔬 Advanced Diagnostics

- IPv6 DNS checks
- DNS-over-HTTPS reachability
- DNS-over-TLS / TLS 853 reachability

### 📊 Results, Comparison & History

- Per-DNS result details
- Individual sample details
- Compare multiple DNS resolvers
- Copy DNS values and reports
- Local test history
- Clear history when needed

### 🎨 Clean Android-first UI

- Persian RTL interface
- Light, dark and system theme modes
- Simple main dashboard
- Advanced details kept behind dedicated screens

## 🧪 Measurement philosophy

NetScope intentionally keeps different measurements separate:

| Measurement | What it means |
|---|---|
| DNS latency | Time to receive a DNS response |
| DNS reliability | How consistently DNS queries receive a response |
| TCP latency | Time to establish a TCP connection |
| TCP connectivity | Whether a TCP connection can be established to the tested destination |
| ICMP ping | Not claimed by NetScope’s DNS/TCP tests |
| In-game ping | Not claimed unless a verified game-server measurement exists |

Results depend on the user’s ISP, routing, network conditions, destination and time of testing.

## 🔐 Security & privacy

NetScope is designed to perform its core diagnostics without an account, API key or intermediary measurement server.

Android permissions are intentionally limited to the networking features the app needs:

- `INTERNET` — network diagnostics
- `ACCESS_NETWORK_STATE` — reading Android network state

The project also keeps cleartext HTTP disabled and Android app backup disabled. No API keys, passwords, tokens or private signing keys belong in this repository.

For public releases, release signing credentials should be kept outside the repository and supplied securely by the build environment.

## 🛠️ Built with

- Flutter / Dart
- Android-first architecture
- Native Android network information through a platform channel
- Direct UDP DNS probing
- TCP connectivity diagnostics
- `shared_preferences` for local settings and history

## ▶️ Run locally

Requirements:

- Flutter SDK
- Android SDK
- Android device or emulator

```bash
flutter pub get
flutter run
```

Build a release APK:

```bash
flutter build apk --release
```

## 🤝 Contributing

Bug reports, reproducible test results, measurement improvements and carefully sourced DNS/endpoint suggestions are welcome.

Please prefer verifiable sources and repeatable measurements over undocumented lists or claims.

## ⚠️ Important limitations

- Network measurements are local observations, not universal rankings.
- A DNS that is fast today may not be the best choice tomorrow.
- DNS latency is not ICMP ping.
- TCP connectivity is not the same as game-server latency.
- A successful TCP connection to Steam or Epic Games does not prove that every game service or game server is reachable.
- A timeout does not by itself prove that a port is closed.

## ❤️ About

NetScope is built around one simple idea:

> **Honest measurement is better than guessing.**

Built with ❤️ by **Gtrezabrm**.

## 📄 License

Choose and add the project license before the first public GitHub release.
