//
//  SceneDelegate.swift
//  Pino-iOS
//
//  Created by Sobhan Eskandari on 11/5/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?

	// MARK: - Private Properties

	private let isLoginUserDefManager = UserDefaultsManager<Bool>(userDefaultKey: .isLogin)
	private let isDevModeUserDefManager = UserDefaultsManager<Bool>(userDefaultKey: .isInDevMode)
	private let biometricCountDefManager = UserDefaultsManager<Int>(userDefaultKey: .showBiometricCounts)
	private let recentAddUserDefManager =
		UserDefaultsManager<[RecentAddressModel]>(userDefaultKey: .recentSentAddresses)
	private let hasShowNotifPageUserDefManager = UserDefaultsManager<Bool>(userDefaultKey: .recentSentAddresses)
	private let securitiesModesUserDefaultsManager = UserDefaultsManager<[String]>(userDefaultKey: .securityModes)

	private var lockScreenView: PrivacyLockView?
	private var authVC: AuthenticationLockManager!
	private var appIsLocked = false
	private var showPrivateScreen = true

	private var isUserLoggedIn: Bool {
		let isUserLoggedInBool: Bool? = isLoginUserDefManager.getValue()
		return isUserLoggedInBool ?? false
	}

	private var lockScreenVC: LockScreenViewController?

	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
		// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
		// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
		// This delegate does not imply the connecting scene or session are new (see
		// `application:configurationForConnectingSceneSession` instead).
		guard let windowScene = (scene as? UIWindowScene) else { return }
		window = UIWindow(windowScene: windowScene)
		isDevModeUserDefManager.registerDefault(value: false)
		hasShowNotifPageUserDefManager.registerDefault(value: false)
		biometricCountDefManager.registerDefault(value: 0)
		securitiesModesUserDefaultsManager.registerDefault(value: [SecurityOptionModel.LockType.immediately.rawValue])
		let emptyRecentAddressList: [RecentAddressModel] = []
		recentAddUserDefManager
			.registerDefault(value: emptyRecentAddressList)

		if isUserLoggedIn {
			window?.rootViewController = TabBarViewController()
		} else {
			let navigationController = CustomNavigationController(rootViewController: IntroViewController())
			window?.rootViewController = navigationController
		}
		window?.makeKeyAndVisible()

		modifyAppLock()

		// Disable animations in test mode to speed up tests
		disableAllAnimationsInTestMode()
	}

	func sceneDidDisconnect(_ scene: UIScene) {
		// Called as the scene is being released by the system.
		// This occurs shortly after the scene enters the background, or when its session is discarded.
		// Release any resources associated with this scene that can be re-created the next time the scene connects.
		// The scene may re-connect later, as its session was not necessarily discarded (see
		// `application:didDiscardSceneSessions` instead).
		print("scene: sceneDidDisconnect: \(appIsLocked)")
	}

	func sceneDidBecomeActive(_ scene: UIScene) {
		// Called when the scene has moved from an inactive state to an active state.
		// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
		print("scene: sceneDidBecomeActive: \(appIsLocked)")
		hideLockView()
	}

	func sceneWillResignActive(_ scene: UIScene) {
		// Called when the scene will move from an active state to an inactive state.
		// This may occur due to temporary interruptions (ex. an incoming phone call).
		print("scene: sceneWillResignActive: \(appIsLocked)")
		showLockView()
	}

	func sceneWillEnterForeground(_ scene: UIScene) {
		// Called as the scene transitions from the background to the foreground.
		// Use this method to undo the changes made on entering the background.
		print("scene: sceneWillEnterForeground: \(appIsLocked)")
		showLockView()
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		// Called as the scene transitions from the foreground to the background.
		// Use this method to save data, release shared resources, and store enough scene-specific state information
		// to restore the scene back to its current state.

		// Save changes in the application's managed object context when the application transitions to the background.
		CoreDataStack.pinoSharedStack.saveContext()
		modifyAppLock()
		dismissLockScreenVC()
		print("scene: sceneDidEnterBackground: \(appIsLocked)")
	}

	// MARK: - Private Methods

	private func modifyAppLock() {
		let securityModes: [String] = securitiesModesUserDefaultsManager.getValue() ?? []
		if securityModes.contains(SecurityOptionModel.LockType.immediately.rawValue) {
			appIsLocked = true
		}
	}

	private func hideLockView() {
		guard isUserLoggedIn == true else { return }

		if showPrivateScreen && !appIsLocked {
			dismissLockScreenVC()
		}
	}

	private func showLockView() {
		guard isUserLoggedIn == true else { return }
		if let window = window {
			if showPrivateScreen && lockScreenVC == nil {
				lockScreenVC = LockScreenViewController(onSuccessLoginClosure: {
					self.appIsLocked = false
					self.dismissLockScreenVC()
				}, shouldUnlockApp: appIsLocked)
				lockScreenVC?.modalPresentationStyle = .overFullScreen
				let rootVC = window.rootViewController
				if rootVC?.presentedViewController != nil {
					rootVC?.presentedViewController?.present(lockScreenVC!, animated: false)
				} else {
					window.rootViewController?.present(lockScreenVC!, animated: false)
				}
			}
		}
	}

	private func dismissLockScreenVC() {
		lockScreenVC?.dismissSelf()
		lockScreenVC = nil
	}

	private func disableAllAnimationsInTestMode() {
		if ProcessInfo.processInfo.arguments.contains(LaunchArguments.isRunningUITests.rawValue) {
			if let scene = UIApplication.shared.connectedScenes.first,
			   let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
			   let window = windowSceneDelegate.window {
				// Disable Core Animations
				window?.layer.speed = 0
			}

			// Disable UIView animations
			UIView.setAnimationsEnabled(false)
		}
	}
}
