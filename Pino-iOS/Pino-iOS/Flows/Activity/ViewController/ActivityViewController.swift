//
//  ActivityViewController.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 12/17/22.
//

import Combine
import UIKit

class ActivityViewController: UIViewController {
	// MARK: - Private Properties

	private let activityVM = ActivityViewModel()
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
		activityVM.refreshUserActivities()
	}

	override func viewWillDisappear(_ animated: Bool) {
		activityVM.destroyTimer()
	}

	// MARK: - Private Methods

	private func setupNavigationBar() {
		setupPrimaryColorNavigationBar()
		setNavigationTitle(activityVM.pageTitle)
	}

	private func setupView() {
        activityEmptyStateView = ActivityEmptyStateView(activityVM: activityVM)
		activityColectionView = ActivityCollectionView(activityVM: activityVM)
		view = activityColectionView
	}
    
    private func setupBindings() {
        activityVM.$userActivities.sink { [weak self] activities in
            guard let isActvitiesEmpty = activities?.isEmpty else {
                self?.view = self?.activityColectionView
                return
            }
            if isActvitiesEmpty {
                self?.view = self?.activityEmptyStateView
            } else {
                self?.view = self?.activityColectionView
            }
        }.store(in: &cancellables)
    }
}
