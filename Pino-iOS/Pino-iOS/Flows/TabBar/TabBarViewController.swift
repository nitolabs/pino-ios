//
//  TabBarViewController.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 12/17/22.
//
// swiftlint: disable trailing_comma

import Combine
import UIKit

class TabBarViewController: UITabBarController {
	// MARK: - Private Properties

	private let tabBarItems: [TabBarItem] = [.home, .swap, .invest, .borrow, .activity]
	private let activityPendingBadgeView = UIView(frame: CGRect(x: 38, y: 8, width: 8, height: 8))
	private var tabBarItemViewControllers = [UIViewController]()
	private var cancellables = Set<AnyCancellable>()

	// MARK: - View Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupView()
		setupTabBarItems()
		presentAllowNotifications()
		setupCustomBadgeStyles()
		setupBindings()
	}

	// MARK: - Private Functions

	private func setupView() {
		tabBar.backgroundColor = .Pino.secondaryBackground

		let appearance = UITabBarAppearance()
		// Tab bar background color
		appearance.backgroundColor = .Pino.secondaryBackground
		appearance.shadowColor = .Pino.gray5
		// Tab title color
		appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
			.foregroundColor: UIColor.Pino.primary,
			.font: UIFont.PinoStyle.SemiboldCaption2!,
		]
		appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
			.foregroundColor: UIColor.Pino.primary,
			.font: UIFont.PinoStyle.mediumCaption2!,
		]
		// Tab icon color
		appearance.stackedLayoutAppearance.normal.iconColor = .Pino.primary
		appearance.stackedLayoutAppearance.selected.iconColor = .Pino.primary

		tabBar.standardAppearance = appearance
		tabBar.scrollEdgeAppearance = appearance
	}

	private func setupTabBarItems() {
		for tabItem in tabBarItems {
			let tabBarItemViewController = tabItem.viewController
			tabBarItemViewController.tabBarItem = UITabBarItem(
				title: tabItem.title,
				image: UIImage(named: tabItem.image),
				selectedImage: UIImage(named: tabItem.selectedImage)
			)
			//            tabBarItemViewController.tabBarItem.badgeValue = ""
			tabBarItemViewControllers.append(tabBarItemViewController)
		}

		viewControllers = tabBarItemViewControllers

		addCustomTabBarBadgeFor(index: 4, customView: activityPendingBadgeView)
	}

	private func presentAllowNotifications() {
		if !UserDefaults.standard.bool(forKey: "hasShownNotifPage") {
			UserDefaults.standard.set(true, forKey: "hasShownNotifPage")
			let allowNotificationsVC = AllowNotificationsViewController()
			present(allowNotificationsVC, animated: true)
		}
	}

	private func setupCustomBadgeStyles() {
		activityPendingBadgeView.backgroundColor = .Pino.orange
		activityPendingBadgeView.layer.cornerRadius = 4
	}

	private func setupBindings() {
		PendingActivitiesManager.shared.$pendingActivitiesList.sink { pendingActivities in
			if pendingActivities.isEmpty {
				self.activityPendingBadgeView.isHidden = true
			} else {
				self.activityPendingBadgeView.isHidden = false
			}
		}.store(in: &cancellables)
	}
}
