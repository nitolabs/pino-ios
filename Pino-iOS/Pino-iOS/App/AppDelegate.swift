//
//  AppDelegate.swift
//  Pino-iOS
//
//  Created by Sobhan Eskandari on 11/5/22.
//

import CoreData
import FirebaseCore
import Kingfisher
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		// Override point for customization after application launch.
		setupNavigationBarCustomBackButton()
		setupLightKeyboardForTextFields()
		setCacheLimitForKingFisherImages()
		setupNotifications()

		setupPushNotifications(application: application)
		return true
	}

	// MARK: UISceneSession Lifecycle

	func application(
		_ application: UIApplication,
		configurationForConnecting connectingSceneSession: UISceneSession,
		options: UIScene.ConnectionOptions
	) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after
		// application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}
}

extension AppDelegate {
	// MARK: - Custom Navigation Bar

	private func setupNavigationBarCustomBackButton() {
		let backImage = UIImage(systemName: "arrow.left")
		let navigationBar = UINavigationBar.appearance()
		navigationBar.backIndicatorImage = backImage
		navigationBar.backIndicatorTransitionMaskImage = backImage
		navigationBar.tintColor = .Pino.label
		navigationBar.overrideUserInterfaceStyle = .light
		navigationBar.shadowImage = UIImage()
	}

	private func setupLightKeyboardForTextFields() {
		UITextField.appearance().keyboardAppearance = .light
	}

	private func setCacheLimitForKingFisherImages() {
		ImageCache.default.diskStorage.config.expiration = .seconds(259_200)
	}

	private func setupNotifications() {
		let notificationsCenter = NotificationCenter.default
		notificationsCenter.addObserver(
			self,
			selector: #selector(didMoveToBackground),
			name: UIApplication.didEnterBackgroundNotification,
			object: nil
		)
		notificationsCenter.addObserver(
			self,
			selector: #selector(didBecomeActive),
			name: UIApplication.didBecomeActiveNotification,
			object: nil
		)
	}

	@objc
	private func didMoveToBackground() {
		PendingActivitiesManager.shared.stopActivityPendingRequests()
	}

	@objc
	private func didBecomeActive() {
		let coreDataManager = CoreDataManager()
		if !coreDataManager.getAllActivities().isEmpty {
			PendingActivitiesManager.shared.startActivityPendingRequests()
		}
	}
}

// MARK: - Push notification conformation

extension AppDelegate: UNUserNotificationCenterDelegate {
	private func setupPushNotifications(application: UIApplication) {
		FirebaseApp.configure() // 1
		_ = PushNotificationManager.shared // 2
		UNUserNotificationCenter.current().delegate = self // 3
		application.registerForRemoteNotifications() // 4
	}

	func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		didReceive response: UNNotificationResponse
	) async {
		let userInfo = response.notification.request.content.userInfo

		// Print full message.
		PushNotificationManager.shared.pushNotifTapped(notificationUserInfo: userInfo)
	}

	func application(
		_ application: UIApplication,
		didReceiveRemoteNotification userInfo: [AnyHashable: Any],
		fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
	) {
		completionHandler(.newData)
	}
}
