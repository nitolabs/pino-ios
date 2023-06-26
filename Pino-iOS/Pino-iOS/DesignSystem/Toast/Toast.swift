//
//  Toast.swift
//  Toast
//
//  Created by Bastiaan Jansen on 27/06/2021.
//

import UIKit

public class Toast {
	/// The direction where the toast will be displayed
	public enum Direction {
		case top
		case bottom
	}

	/// Built-in animations for your toast
	public enum AnimationType {
		/// Use this type for fading in/out animations.
		case slide(x: CGFloat, y: CGFloat)

		/// Use this type for fading in/out animations.
		///
		/// alphaValue must be greater or equal to 0 and less or equal to 1.
		case fade(alphaValue: CGFloat)

		/// Use this type for scaling and slide in/out animations.
		case scaleAndSlide(scaleX: CGFloat, scaleY: CGFloat, x: CGFloat, y: CGFloat)

		/// Use this type for scaling in/out animations.
		case scale(scaleX: CGFloat, scaleY: CGFloat)

		/// Use this type for giving your own affine transformation
		case custom(transformation: CGAffineTransform)

		/// Currently the default animation if no explicit one specified.
		case `default`
	}

	private var closeTimer: Timer?

	/// This is for pan gesture to close.
	private var startY: CGFloat = 0
	private var startShiftY: CGFloat = 0

	public static var defaultImageTint: UIColor {
		if #available(iOS 13.0, *) {
			return .label
		} else {
			return .black
		}
	}

	public let view: ToastView

	public weak var delegate: ToastDelegate?

	private let config: ToastConfiguration

	private(set) var direction: Direction

	/// Creates a new Toast with the default Apple style layout with a title and an optional subtitle.
	/// - Parameters:
	///   - title: Attributed title which is displayed in the toast view
	///   - subtitle: Optional attributed subtitle which is displayed in the toast view
	///   - config: Configuration options
	/// - Returns: A new Toast view with the configured layout
	public static func text(
		_ title: NSAttributedString,
		subtitle: NSAttributedString? = nil,
		direction: Direction = .bottom,
		config: ToastConfiguration = ToastConfiguration()
	) -> Toast {
		let view = AppleToastView(child: TextToastView(title, subtitle: subtitle))
		var overriddenConfig = config
		overriddenConfig.direction = direction
		return self.init(view: view, config: overriddenConfig)
	}

	/// Creates a new Toast with the default Apple style layout with a title and an optional subtitle.
	/// - Parameters:
	///   - title: Title which is displayed in the toast view
	///   - subtitle: Optional subtitle which is displayed in the toast view
	///   - config: Configuration options
	/// - Returns: A new Toast view with the configured layout
	public static func text(
		_ title: String,
		subtitle: String? = nil,
		style: Style = .primary,
		direction: Direction = .bottom,
		config: ToastConfiguration = ToastConfiguration()
	) -> Toast {
		let view = AppleToastView(child: TextToastView(title, subtitle: subtitle), style: style)
		var overriddenConfig = config
		overriddenConfig.direction = direction
		return self.init(view: view, config: overriddenConfig)
	}

	/// Creates a new Toast with the default Apple style layout with an icon, title and optional subtitle.
	/// - Parameters:
	///   - image: Image which is displayed in the toast view
	///   - imageTint: Tint of the image
	///   - title: Attributed title which is displayed in the toast view
	///   - subtitle: Optional attributed subtitle which is displayed in the toast view
	///   - config: Configuration options
	/// - Returns: A new Toast view with the configured layout

	public static func `default`(
		title: NSAttributedString,
		subtitle: NSAttributedString? = nil,
		style: Style = .primary,
		direction: Direction = .bottom,
		config: ToastConfiguration = ToastConfiguration()
	) -> Toast {
		let view = AppleToastView(
			child: IconAppleToastView(image: style.image, imageTint: style.tintColor, title: title, subtitle: subtitle),
			style: style
		)
		var overriddenConfig = config
		overriddenConfig.direction = direction
		return self.init(view: view, config: overriddenConfig)
	}

	/// Creates a new Toast with the default Apple style layout with an icon, title and optional subtitle.
	/// - Parameters:
	///   - image: Image which is displayed in the toast view
	///   - imageTint: Tint of the image
	///   - title: Title which is displayed in the toast view
	///   - subtitle: Optional subtitle which is displayed in the toast view
	///   - config: Configuration options
	/// - Returns: A new Toast view with the configured layout
	public static func `default`(
		title: String,
		subtitle: String? = nil,
		style: Style = .primary,
		direction: Direction = .bottom,
		config: ToastConfiguration = ToastConfiguration()
	) -> Toast {
		let view = AppleToastView(
			child: IconAppleToastView(image: style.image, imageTint: style.tintColor, title: title, subtitle: subtitle),
			style: style
		)
		var overriddenConfig = config
		overriddenConfig.direction = direction
		return self.init(view: view, config: overriddenConfig)
	}

	/// Creates a new Toast with a custom view
	/// - Parameters:
	///   - view: A view which is displayed when the toast is shown
	///   - config: Configuration options
	/// - Returns: A new Toast view with the configured layout
	public static func custom(
		view: ToastView,
		config: ToastConfiguration = ToastConfiguration()
	) -> Toast {
		self.init(view: view, config: config)
	}

	/// Creates a new Toast with a custom view
	/// - Parameters:
	///   - view: A view which is displayed when the toast is shown
	///   - config: Configuration options
	/// - Returns: A new Toast view with the configured layout
	public required init(view: ToastView, config: ToastConfiguration) {
		self.config = config
		self.view = view
		self.direction = config.direction

		if config.enablePanToClose {
			enablePanToClose()
		}
	}

	#if !os(tvOS)
		/// Show the toast with haptic feedback
		/// - Parameters:
		///   - type: Haptic feedback type
		///   - time: Time after which the toast is shown
		public func show(haptic type: UINotificationFeedbackGenerator.FeedbackType, after time: TimeInterval = 0) {
			UINotificationFeedbackGenerator().notificationOccurred(type)
			show(after: time)
		}
	#endif

	/// Show the toast
	/// - Parameter delay: Time after which the toast is shown
	public func show(after delay: TimeInterval = 0) {
        let buttomToastViewTag = 900
        let topToastViewTag = 1000
        var currentUsingTag: Int!
        switch config.direction {
        case .top:
            currentUsingTag = topToastViewTag
        case .bottom:
            currentUsingTag = buttomToastViewTag
        }
        
        let toastViewInViewHierarchy = config.view?.viewWithTag(currentUsingTag) ?? topController()?.view.viewWithTag(currentUsingTag)
        view.tag = currentUsingTag
        
        if let toastViewInViewHierarchy {
            close(completion: { [weak self] in
                if self?.config.view?.viewWithTag(currentUsingTag) ?? self?.topController()?.view.viewWithTag(currentUsingTag) == nil {
                self?.animateToast(delay: delay)
                }
            }, customView: toastViewInViewHierarchy)
        } else {
            animateToast(delay: delay)
                }
	}

	/// Close the toast
	/// - Parameters:
	///   - completion: A completion handler which is invoked after the toast is hidden
    public func close(completion: (() -> Void)? = nil, customView: UIView? = nil) {
		delegate?.willCloseToast(self)
        
        let selectedView = customView ?? self.view

		UIView.animate(
			withDuration: config.animationTime,
			delay: 0,
			usingSpringWithDamping: 1,
			initialSpringVelocity: 0.6,
			options: [.curveEaseIn, .allowUserInteraction],
			animations: {
				self.config.exitingAnimation.apply(to: selectedView)
			},
			completion: { _ in
                selectedView.removeFromSuperview()
				completion?()
				self.delegate?.didCloseToast(self)
			}
		)
	}
    
    private func animateToast(delay: TimeInterval) {
        config.view?.addSubview(view) ?? topController()?.view.addSubview(view)
        view.createView(for: self)
        
        delegate?.willShowToast(self)
        
        config.enteringAnimation.apply(to: view)
        UIView.animate(
            withDuration: config.animationTime,
            delay: delay,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.6,
            options: [.curveEaseOut, .allowUserInteraction]
        ) {
            self.config.enteringAnimation.undo(from: self.view)
        } completion: { [self] _ in
            delegate?.didShowToast(self)
            closeTimer = Timer.scheduledTimer(withTimeInterval: .init(config.displayTime), repeats: false) { [self] _ in
                if config.autoHide {
                    close()
                }
            }
        }
    }

	private func topController() -> UIViewController? {
		if var topController = keyWindow()?.rootViewController {
			while let presentedViewController = topController.presentedViewController {
				topController = presentedViewController
			}
			return topController
		}
		return nil
	}

	private func keyWindow() -> UIWindow? {
		if #available(iOS 13.0, *) {
			for scene in UIApplication.shared.connectedScenes {
				guard let windowScene = scene as? UIWindowScene else {
					continue
				}
				if windowScene.windows.isEmpty {
					continue
				}
				guard let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
					continue
				}
				return window
			}
			return nil
		} else {
			return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension Toast {
	private func enablePanToClose() {
		let pan = UIPanGestureRecognizer(target: self, action: #selector(toastOnPan(_:)))
		view.addGestureRecognizer(pan)
	}

	@objc
	private func toastOnPan(_ gesture: UIPanGestureRecognizer) {
		guard let topVc = topController() else {
			return
		}

		switch gesture.state {
		case .began:
			startY = view.frame.origin.y
			startShiftY = gesture.location(in: topVc.view).y
			closeTimer?.invalidate() // prevent timer to fire close action while being touched
		case .changed:
			let delta = gesture.location(in: topVc.view).y - startShiftY
			switch direction {
			case .top:
				if delta <= 0 {
					view.frame.origin.y = startY + delta
				}
			case .bottom:
				if delta >= 0 {
					view.frame.origin.y = startY + delta
				}
			}
		case .ended:
			let threshold = 15.0 // if user drags more than threshold the toast will be dismissed
			let ammountOfUserDragged = abs(startY - view.frame.origin.y)
			let shouldDismissToast = ammountOfUserDragged > threshold

			if shouldDismissToast {
				close()
			} else {
				UIView.animate(
					withDuration: config.animationTime,
					delay: 0,
					options: [.curveEaseOut, .allowUserInteraction]
				) {
					self.view.frame.origin.y = self.startY
				} completion: { [self] _ in
					closeTimer = Timer
						.scheduledTimer(withTimeInterval: .init(config.displayTime), repeats: false) { [self] _ in
							if config.autoHide {
								close()
							}
						}
				}
			}

		case .cancelled, .failed:
			closeTimer = Timer.scheduledTimer(withTimeInterval: .init(config.displayTime), repeats: false) { [self] _ in
				if config.autoHide {
					close()
				}
			}
		default:
			break
		}
	}

	public func enableTapToClose() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(toastOnTap))
		view.addGestureRecognizer(tap)
	}

	@objc
	public func toastOnTap(_ gesture: UITapGestureRecognizer) {
		closeTimer?.invalidate()
		close()
	}
}

extension Toast.AnimationType {
	/// Applies the effects to the ToastView.
	fileprivate func apply(to view: UIView) {
		switch self {
		case let .slide(x: x, y: y):
			view.transform = CGAffineTransform(translationX: x, y: y)
		case let .fade(value):
			view.alpha = value

		case let .scaleAndSlide(scaleX, scaleY, x, y):
			view.transform = CGAffineTransform(scaleX: scaleX, y: scaleY).translatedBy(x: x, y: y)

		case let .scale(scaleX, scaleY):
			view.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)

		case let .custom(transformation):
			view.transform = transformation

		case .default:
			break
		}
	}

	/// Undo the effects from the ToastView so that it never happened.
	fileprivate func undo(from view: UIView) {
		switch self {
		case .slide, .scaleAndSlide, .scale, .custom:
			view.transform = .identity

		case .fade:
			view.alpha = 1.0

		case .default:
			break
		}
	}
}

extension Toast {
	public struct Style {
		var tintColor: UIColor
		var backgroundColor: UIColor
		var image: UIImage
	}
}

extension Toast.Style {
	public static let primary = Toast.Style(
		tintColor: .Pino.white,
		backgroundColor: .Pino.primary,
		image: .init(systemName: "info.circle")!
	)

	public static let copy = Toast.Style(
		tintColor: .Pino.white,
		backgroundColor: .Pino.primary,
		image: .init(systemName: "doc.on.doc")!
	)

	public static let secondary = Toast.Style(
		tintColor: .Pino.black,
		backgroundColor: .Pino.white,
		image: .init(systemName: "info.circle")!
	)

	public static let error = Toast.Style(
		tintColor: .Pino.errorRed,
		backgroundColor: .Pino.white,
		image: .init(systemName: "exclamationmark.triangle")!
	)
}
