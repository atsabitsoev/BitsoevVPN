//
//  ServersService.swift
//  BitsoevVPN
//
//  Created by Ацамаз Бицоев on 19.04.2023.
//

import Darwin

final class ServersService {
    func loadServers(_ completion: @escaping ([ServerInfo]) -> Void) {
        sleep(5)
        completion([
            ServerInfo(title: "Austria", ip: "77.73.131.166"),
            ServerInfo(title: "England", ip: "77.73.131.166")
        ])
    }
}
