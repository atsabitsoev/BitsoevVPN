//
//  Vibration.swift
//  BitsoevVPN
//
//  Created by Ацамаз Бицоев on 23.04.2023.
//

import UIKit


enum Vibration {
    case heavy
    case error
    case light


    func execute() {
        switch self {
        case .heavy:
            vibrateHeavy()
        case .error:
            vibrateError()
        case .light:
            vibrateLight()
        }
    }
}


private extension Vibration {
    func vibrateHeavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }

    func vibrateError() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }

    func vibrateLight() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
