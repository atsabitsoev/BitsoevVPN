//
//  BigSwitcherImages.swift
//  BitsoevVPN
//
//  Created by Ацамаз Бицоев on 19.04.2023.
//

import UIKit

enum BigSwitcherImages {
    case background
    case on
    case off
    case neutral
}


extension BigSwitcherImages {
    var image: UIImage {
        switch self {
        case .background:
            return UIImage(named: "SwitchBackground")!
        case .on:
            return UIImage(named: "SwitchControlOn")!
        case .off:
            return UIImage(named: "SwitchControlOff")!
        case .neutral:
            return UIImage(named: "SwitchControlNeutral")!
        }
    }
}
