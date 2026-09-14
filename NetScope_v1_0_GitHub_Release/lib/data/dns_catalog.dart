import '../domain/models/dns_server.dart';

const dnsCatalog = <DnsServer>[
  DnsServer(id: 'cloudflare', name: 'Cloudflare', primary: '1.1.1.1', secondary: '1.0.0.1', primaryV6: '2606:4700:4700::1111', secondaryV6: '2606:4700:4700::1001', region: DnsRegion.global, description: 'رزولور عمومی سریع و Anycast'),
  DnsServer(id: 'google', name: 'Google Public DNS', primary: '8.8.8.8', secondary: '8.8.4.4', primaryV6: '2001:4860:4860::8888', secondaryV6: '2001:4860:4860::8844', region: DnsRegion.global, description: 'رزولور عمومی Google'),
  DnsServer(id: 'quad9', name: 'Quad9', primary: '9.9.9.9', secondary: '149.112.112.112', primaryV6: '2620:fe::fe', secondaryV6: '2620:fe::9', region: DnsRegion.global, description: 'رزولور عمومی با تمرکز امنیتی'),
  DnsServer(id: 'opendns', name: 'OpenDNS', primary: '208.67.222.222', secondary: '208.67.220.220', primaryV6: '2620:119:35::35', secondaryV6: '2620:119:53::53', region: DnsRegion.global, description: 'Cisco OpenDNS'),
  DnsServer(id: 'verisign', name: 'Verisign', primary: '64.6.64.6', secondary: '64.6.65.6', region: DnsRegion.global, description: 'Verisign Public DNS'),
  DnsServer(id: 'adguard', name: 'AdGuard DNS', primary: '94.140.14.14', secondary: '94.140.15.15', primaryV6: '2a10:50c0::ad1:ff', secondaryV6: '2a10:50c0::ad2:ff', region: DnsRegion.global, description: 'رزولور عمومی AdGuard'),
  DnsServer(id: 'cleanbrowsing', name: 'CleanBrowsing', primary: '185.228.168.9', secondary: '185.228.169.9', region: DnsRegion.global, description: 'رزولور عمومی با فیلتر خانواده'),
  DnsServer(id: 'controld', name: 'Control D', primary: '76.76.2.0', secondary: '76.76.10.0', region: DnsRegion.global, description: 'رزولور عمومی Control D'),
  DnsServer(id: 'dnswatch', name: 'DNS.WATCH', primary: '84.200.69.80', secondary: '84.200.70.40', region: DnsRegion.global, description: 'رزولور عمومی'),
  DnsServer(id: 'mullvad', name: 'Mullvad DNS', primary: '194.242.2.2', secondary: '194.242.2.3', region: DnsRegion.global, description: 'رزولور عمومی Mullvad'),
  DnsServer(id: 'electro', name: 'Electro', primary: '78.157.42.100', secondary: '78.157.42.101', region: DnsRegion.iran, description: 'DNS عمومی ایران'),
  DnsServer(id: 'shecan', name: 'Shecan', primary: '178.22.122.100', secondary: '185.51.200.2', region: DnsRegion.iran, description: 'DNS سرویس شکن'),
  DnsServer(id: 'begzar', name: 'Begzar', primary: '185.55.226.26', secondary: '185.55.225.25', region: DnsRegion.iran, description: 'DNS عمومی ایران'),
  DnsServer(id: 'tci', name: 'TCI / مخابرات', primary: '5.200.200.200', secondary: '217.218.127.127', region: DnsRegion.iran, description: 'DNS فهرست‌شده برای مخابرات ایران؛ وضعیت با تست فعلی مشخص می‌شود'),
  DnsServer(id: 'parsonline', name: 'Pars Online', primary: '37.10.64.1', secondary: '37.10.65.1', region: DnsRegion.iran, description: 'DNS فهرست‌شده برای پارس‌آنلاین؛ وضعیت با تست فعلی مشخص می‌شود'),
  DnsServer(id: 'ipm', name: 'IPM', primary: '194.225.152.10', secondary: '194.225.152.12', region: DnsRegion.iran, description: 'رزولورهای عمومی فهرست‌شده IPM'),
  DnsServer(id: 'bertina', name: 'Bertina', primary: '193.186.32.32', secondary: '', region: DnsRegion.iran, description: 'DNS فهرست‌شده Bertina'),
];
