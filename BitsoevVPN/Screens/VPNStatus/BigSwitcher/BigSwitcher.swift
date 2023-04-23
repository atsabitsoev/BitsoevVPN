//
//  BigSwitcher.swift
//  BitsoevVPN
//
//  Created by Ацамаз Бицоев on 19.04.2023.
//

import UIKit

final class BigSwitcher: UIView {
    private let backgroundImageView: UIView = {
        let view = UIImageView(image: BigSwitcherImages.background.image)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let switcherImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var switcherTopConstraint = switcherImageView.topAnchor.constraint(equalTo: backgroundImageView.topAnchor, constant: -8)
    private lazy var switcherBottomConstraint = switcherImageView.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: 11)


    private var state: BigSwitcherState
    private var startTouchY: CGFloat = .zero
    private var totalInset: CGFloat = .zero


    private let actionLoadingOn: () -> Void
    private let actionLoadingOff: () -> Void


    init(
        state: BigSwitcherState,
        actionLoadingOn: @escaping () -> Void,
        actionLoadingOff: @escaping () -> Void
    ) {
        self.state = state
        self.actionLoadingOn = actionLoadingOn
        self.actionLoadingOff = actionLoadingOff
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        super.updateConstraints()
        setBackgroundImageViewConstraints()
        setSwitcherImageViewConstraints()
    }


    func setOffState(withError: Bool = false) {
        guard state != .off else { return }
        state = .off
        activateSwitcherActualConstraints()
        let vibration = withError ? Vibration.error : Vibration.heavy
        setSwitcherActualState(animateOnOff: withError, onOffVibration: vibration)
    }

    func setOnState(withError: Bool = false) {
        guard state != .on else { return }
        state = .on
        activateSwitcherActualConstraints()
        let vibration = withError ? Vibration.error : Vibration.heavy
        setSwitcherActualState(animateOnOff: withError, onOffVibration: vibration)
    }
}


// MARK: - Setup
private extension BigSwitcher {
    func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        setNeedsUpdateConstraints()
        addSubview(backgroundImageView)
        addSubview(switcherImageView)
        setSwitcherActualState(animateOnOff: false)
    }

    func setSwitcherActualState(animateOnOff: Bool, onOffVibration: Vibration? = nil) {
        switch state {
        case .off:
            onOffVibration?.execute()
            isUserInteractionEnabled = true
            switcherImageView.layer.removeAllAnimations()
            setSwitcherToIdentity(animated: animateOnOff)
            switcherImageView.image = BigSwitcherImages.off.image
        case .on:
            onOffVibration?.execute()
            isUserInteractionEnabled = true
            setSwitcherToIdentity(animated: animateOnOff)
            switcherImageView.image = BigSwitcherImages.on.image
        case .onLoading:
            Vibration.light.execute()
            isUserInteractionEnabled = false
            setOnLoadingAnimation()
            actionLoadingOn()
        case .offLoading:
            Vibration.light.execute()
            isUserInteractionEnabled = false
            setOffLoadingAnimation()
            actionLoadingOff()
        }
    }

    func setSwitcherToIdentity(animated: Bool) {
        switcherImageView.layer.removeAllAnimations()
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.switcherImageView.transform = .identity
            }
        } else {
            self.switcherImageView.transform = .identity
        }
    }
}


// MARK: - Touches
extension BigSwitcher {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        startTouchY = touches.first?.location(in: self).y ?? .zero
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let currentY: CGFloat = touches.first?.location(in: self).y ?? .zero
        let totalInset: CGFloat = currentY - startTouchY
        self.totalInset = totalInset
        moveSwitcher()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        moveSwitcher()
        clearTouch()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        moveSwitcher()
        clearTouch()
    }

    private func moveSwitcher() {
        let minInset: CGFloat
        let maxInset: CGFloat
        if state == .off {
            minInset = Constants.topTouch
            maxInset = .zero
        } else if state == .on {
            minInset = .zero
            maxInset = Constants.bottomTouch
        } else {
            minInset = .zero
            maxInset = .zero
        }
        let transformY: CGFloat
        if totalInset > maxInset {
            transformY = maxInset
        } else if totalInset < minInset {
            transformY = minInset
        } else {
            transformY = totalInset
        }
        switcherImageView.transform = CGAffineTransform(translationX: CGFloat.zero, y: transformY)
    }

    private func clearTouch() {
        if state == .off, totalInset <= Constants.topTouch {
            state = .onLoading
        } else if state == .on, totalInset >= Constants.bottomTouch {
            state = .offLoading
        }
        setSwitcherActualState(animateOnOff: true)
        startTouchY = .zero
        totalInset = .zero
    }
}


// MARK: - Animations
private extension BigSwitcher {
    func setOnLoadingAnimation() {
        let animation = CABasicAnimation(keyPath: "contents")
        animation.duration = 0.3
        animation.fromValue = BigSwitcherImages.on.image.cgImage
        animation.toValue = BigSwitcherImages.neutral.image.cgImage
        animation.autoreverses = true
        animation.repeatCount = .infinity
        switcherImageView.layer.add(animation, forKey: nil)
    }

    func setOffLoadingAnimation() {
        let animation = CABasicAnimation(keyPath: "contents")
        animation.duration = 0.3
        animation.fromValue = BigSwitcherImages.off.image.cgImage
        animation.toValue = BigSwitcherImages.neutral.image.cgImage
        animation.autoreverses = true
        animation.repeatCount = .infinity
        switcherImageView.layer.add(animation, forKey: nil)
    }
}


// MARK: - Constraints
private extension BigSwitcher {
    func setBackgroundImageViewConstraints() {
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.widthAnchor.constraint(equalToConstant: 124),
            backgroundImageView.heightAnchor.constraint(equalToConstant: 284)
        ])
    }

    func setSwitcherImageViewConstraints() {
        NSLayoutConstraint.activate([
            switcherImageView.centerXAnchor.constraint(equalTo: backgroundImageView.centerXAnchor),
            switcherImageView.widthAnchor.constraint(equalToConstant: 144),
            switcherImageView.heightAnchor.constraint(equalToConstant: 208)
        ])
        activateSwitcherActualConstraints()
    }

    func activateSwitcherActualConstraints() {
        switch state {
        case .off, .offLoading:
            switcherTopConstraint.isActive = false
            switcherBottomConstraint.isActive = true
        case .on, .onLoading:
            switcherBottomConstraint.isActive = false
            switcherTopConstraint.isActive = true
        }
    }
}


// MARK: - Constants
private extension BigSwitcher {
    enum Constants {
        /// Верхняя граница при state == .off
        static var topTouch: CGFloat { -95 }
        /// Нижняя граница при state == .on
        static var bottomTouch: CGFloat { 95 }
    }
}
