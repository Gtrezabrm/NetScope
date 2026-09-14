package com.netscope.app

import android.content.Context
import android.net.ConnectivityManager
import android.net.LinkProperties
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.Inet4Address

class MainActivity : FlutterActivity() {
    private val channelName = "netscope/network"
    private var callback: MethodChannel.Result? = null
    private var networkCallback: ConnectivityManager.NetworkCallback? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        channel.setMethodCallHandler { call, result ->
            if (call.method == "getNetworkInfo") {
                result.success(readNetworkInfo())
            } else {
                result.notImplemented()
            }
        }
    }

    private fun readNetworkInfo(): Map<String, Any?> {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val active = cm.activeNetwork
        if (active == null) {
            return mapOf(
                "connected" to false,
                "validated" to false,
                "transport" to "بدون اتصال",
                "dnsServers" to emptyList<String>(),
                "ipv6" to emptyList<String>()
            )
        }

        val caps = cm.getNetworkCapabilities(active)
        val lp = cm.getLinkProperties(active)
        val connected = caps != null && caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
        val validated = Build.VERSION.SDK_INT < 23 || (caps?.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED) == true)

        val transport = when {
            caps?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true -> "Wi‑Fi"
            caps?.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) == true -> "دیتای همراه"
            caps?.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) == true -> "Ethernet"
            Build.VERSION.SDK_INT >= 23 && caps?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) == true -> "VPN"
            else -> "شبکه دیگر"
        }

        val dns = lp?.dnsServers?.map { it.hostAddress ?: "" }?.filter { it.isNotBlank() } ?: emptyList()
        val ipv6 = lp?.linkAddresses?.mapNotNull { it.address.hostAddress }
            ?.filter { it.contains(":") } ?: emptyList()
        val ipv4 = lp?.linkAddresses?.map { it.address }
            ?.firstOrNull { it is Inet4Address }
            ?.hostAddress

        return mapOf(
            "connected" to connected,
            "validated" to validated,
            "transport" to transport,
            "dnsServers" to dns,
            "ipv4" to ipv4,
            "ipv6" to ipv6
        )
    }

    override fun onDestroy() {
        callback = null
        networkCallback?.let {
            val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            runCatching { cm.unregisterNetworkCallback(it) }
        }
        networkCallback = null
        super.onDestroy()
    }
}
