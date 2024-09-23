//
//  ActivityViewController.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 12/17/22.
//

import Combine
import UIKit

class ActivityViewController: UIViewController {
	// MARK: - Public Properties

	public var shouldOpenActivityTXHash: String?

	// MARK: - Private Properties

	private let activityVM = ActivityViewModel()
	private let hapticManager = HapticManager()
	private var activityEmptyStateView: ActivityEmptyStateView!
	private var activityColectionView: ActivityCollectionView!
	private var cancellables = Set<AnyCancellable>()

	// MARK: - View Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func loadView() {
		setupView()
		setupNavigationBar()
		setupBindings()
	}

	override func viewWillAppear(_ animated: Bool) {
		activityVM.getUserActivitiesFromVC()
		if activityVM.userActivityCellVMList == nil {
			activityColectionView.toggleLoading(isLoading: true)
		}
		setupLoading()
	}

	override func viewWillDisappear(_ animated: Bool) {
		activityVM.destroyTimer()
		activityVM.cancellPendingActivitiesBinding()
	}

	// MARK: - Private Methods

	private func setupNavigationBar() {
		setupPrimaryColorNavigationBar()
		setNavigationTitle(activityVM.pageTitle)
	}

	private func setupView() {
		activityColectionView = ActivityCollectionView(
			activityVM: activityVM,
			openActivityDetailsClosure: { [weak self] activityDetails in
				self?.openActivityDetailsPage(activityDetails: activityDetails)
			}
		)
		activityEmptyStateView = ActivityEmptyStateView(
			titleText: activityVM.noActivityTitleText,
			titleImageName: activityVM.noActivityIconName,
			descriptionText: activityVM.noActivityDescriptionText
		)
		view = activityColectionView
	}

	private func openActivityDetailsPage(activityDetails: ActivityCellViewModel) {
		hapticManager.run(type: .lightImpact)
		let navigationVC = UINavigationController()
		let activityDetailsVC = ActivityDetailsViewController(activityDetails: activityDetails)
		navigationVC.viewControllers = [activityDetailsVC]
		present(navigationVC, animated: true)
	}

	private func openActivityDetailsFromNotification(activities: [ActivityCellViewModel]) {
		guard let shouldOpenActivityTXHash else {
			return
		}
		let selectedActivity = activities
			.first(where: { $0.activityModel.txHash.lowercased() == shouldOpenActivityTXHash.lowercased() })
		openActivityDetailsPage(activityDetails: selectedActivity!)
		self.shouldOpenActivityTXHash = nil
	}

	private func setupBindings() {
		activityVM.$userActivityCellVMList.sink { [weak self] activities in
			guard let isActvitiesEmpty = activities?.isEmpty else {
				self?.view = self?.activityColectionView
				return
			}
			if isActvitiesEmpty {
				self?.view = self?.activityEmptyStateView
			} else {
				self?.openActivityDetailsFromNotification(activities: activities!)
				self?.view = self?.activityColectionView
			}
		}.store(in: &cancellables)
	}

	private func setupLoading() {
		activityColectionView?.$showLoading.sink { showLoading in
			if showLoading {
				self.view.showGradientSkeletonView(endLocation: 0.3)
			} else {
				self.view.hideGradientSkeletonView()
			}
		}.store(in: &cancellables)
	}
}
