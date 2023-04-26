//
//  ViewController.swift
//  BitsoevVPN
//
//  Created by Ацамаз Бицоев on 16.04.2023.
//

import UIKit
import NetworkExtension

final class VPNStatusVC: UIViewController {
    private let vpnService = VPNService.shared
    private let serversService = ServersService()
    private var currentStatus: NEVPNStatus? = nil

    private var timeoutTimer: Timer?


    private lazy var bigSwitcher = BigSwitcher(
        state: .off,
        actionLoadingOn: self.vpnService.connect,
        actionLoadingOff: self.vpnService.disconnect
    )


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        observe()
        loadVpnStatus()
        serversService.loadServers { resp in
            
        }
    }
}


// MARK: - Setup
private extension VPNStatusVC {
    private func observe() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateVpnStatus), name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
    }

    private func setupUI() {
        view.backgroundColor = UIColor.Bitsoev.backgroundColor

        view.addSubview(bigSwitcher)

        bigSwitcher.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bigSwitcher.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}


// MARK: - VPNStatus
private extension VPNStatusVC {
    func setVpnStatus(_ status: NEVPNStatus?) {
        setUIForVpnStatus(status)
        if let status = status, (status == .connecting || status == .disconnecting) {
            setTimeout(for: status)
        }
        currentStatus = status
    }

    func setUIForVpnStatus(_ status: NEVPNStatus?) {
        print(status.debugDescription)
        switch status {
        case .connected:
            bigSwitcher.setOnState()
        case .disconnected:
            bigSwitcher.setOffState()
        default:
            break
        }
    }

    func setTimeout(for status: NEVPNStatus) {
        if status == .connecting {
            timeoutTimer?.invalidate()
            timeoutTimer = nil
            timeoutTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { [weak self] _ in
                guard let self = self else { return }
                self.timeoutTimer?.invalidate()
                self.timeoutTimer = nil
                if self.currentStatus == status {
                    if status == .connecting {
                        self.bigSwitcher.setOffState()
                    } else if status == .disconnecting {
                        self.bigSwitcher.setOnState()
                    }
                }
            })
        }
    }

    func loadVpnStatus() {
        vpnService.initManagerIfNeeded { [weak self] status in
            self?.setVpnStatus(status)
        }
    }

    @objc func updateVpnStatus() {
        let status = vpnService.getStatus()
        guard status != currentStatus else { return }
        setVpnStatus(status)
    }
}
