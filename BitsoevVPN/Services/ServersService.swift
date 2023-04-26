//
//  ServersService.swift
//  BitsoevVPN
//
//  Created by Ацамаз Бицоев on 19.04.2023.
//

import Darwin
import FirebaseDatabase


final class ServersService {
    private let db: DatabaseReference = Database.database(url: "https://bitsoev-vpn-default-rtdb.europe-west1.firebasedatabase.app").reference()
    
    
    func loadServers(_ completion: @escaping (ServersResponse) -> Void) {
        db.child("servers").queryOrderedByKey().getData { _, snapshot in
            guard let snapshot = snapshot else {
                completion(.error)
                return
            }
            completion(.success(snapshot.serverInfos()))
        }
    }
}


// MARK: - Parsing
private extension DataSnapshot {
    func serverInfos() -> [ServerInfo] {
        let array = value as? NSArray
        let dictionaries: [NSDictionary] = array?.compactMap({ $0 as? NSDictionary }) ?? []
        let serverInfos: [ServerInfo] = dictionaries.map { dictionary -> ServerInfo in
            let ip: String = dictionary.value(forKey: "ip") as? String ?? ""
            let name: String = dictionary.value(forKey: "name") as? String ?? ""
            let ovpnFileUrl: String = dictionary.value(forKey: "ovpnFileUrl") as? String ?? ""
            return ServerInfo(
                ip: ip,
                name: name,
                ovpnFileUrl: ovpnFileUrl
            )
        }
        return serverInfos
    }
}
