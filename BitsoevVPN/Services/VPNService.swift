//
//  VPNService.swift
//  BitsoevVPN
//
//  Created by Ацамаз Бицоев on 17.04.2023.
//

import NetworkExtension


final class VPNService {
    private init() {}
    static let shared = VPNService()


    private let providerLoadLock = NSLock()


    private var providerManager: NETunnelProviderManager?


    func connect() {
        loadProviderManager {
            self.configureVPN(serverAddress: "77.73.131.166", username: "root", password: "Biznes1997")
        }
    }

    func disconnect() {
        providerManager?.connection.stopVPNTunnel()
    }

    func initManagerIfNeeded(_ handler: @escaping (NEVPNStatus?) -> Void) {
        if let providerManager {
            handler(providerManager.connection.status)
        } else {
            loadProviderManager { [weak self] in
                handler(self?.providerManager?.connection.status)
            }
        }
    }

    func getStatus() -> NEVPNStatus? {
        providerManager?.connection.status
    }
}

private extension VPNService {
    func loadProviderManager(completion:@escaping () -> Void) {
        providerLoadLock.lock()
        NETunnelProviderManager.loadAllFromPreferences { [weak self] (managers, error) in
            if error == nil {
                self?.providerManager = managers?.first ?? NETunnelProviderManager()
                completion()
            }
            self?.providerLoadLock.unlock()
        }
    }

    func configureVPN(serverAddress: String, username: String, password: String) {
        providerManager?.loadFromPreferences { error in
            if error == nil, let providerManager = self.providerManager {
                let tunnelProtocol = NETunnelProviderProtocol()
                tunnelProtocol.username = username
                tunnelProtocol.serverAddress = serverAddress
                tunnelProtocol.providerBundleIdentifier = "com.bitsoev.bitsoevpnapp.BitsoevNetworkExtension"
                tunnelProtocol.providerConfiguration = ["ovpn": self.getOVPNData()!, "username": username, "password": password]
                tunnelProtocol.disconnectOnSleep = false
                providerManager.protocolConfiguration = tunnelProtocol
                providerManager.localizedDescription = "Bitsoev VPN"
                providerManager.isEnabled = true
                providerManager.saveToPreferences(completionHandler: { (error) in
                    if error == nil  {
                        providerManager.loadFromPreferences(completionHandler: { (error) in
                            do {
                                try providerManager.connection.startVPNTunnel()
                            } catch let error {
                                print(error.localizedDescription)
                            }
                        })
                    }
                })
            }
        }
    }

    func getOVPNData() -> Any? {
        if let fileURL = Bundle.main.url(forResource: "myMac", withExtension: "ovpn") {
            do {
                // Read the file contents into a string
                let fileContents = try String(contentsOf: fileURL, encoding: .utf8)

                // Print the file contents
                print("OVPN file read")
                return fileContents

            } catch let error {
                print("Error reading file: \(error.localizedDescription)")
            }
        } else {
            print("File not found in bundle.")
        }
        return nil
    }
}
