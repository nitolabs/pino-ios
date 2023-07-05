//
//  CoinInfoCollectionView.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 2/17/23.
//

import Combine
import UIKit

class ActivitiesCollectionView: UICollectionView {
	// MARK: - Private Properties

	private var cancellable = Set<AnyCancellable>()
	private let historyRefreshContorl = UIRefreshControl()
	private var coinInfoVM: CoinInfoViewModel!
	private var separatedActivities: ActivityHelper.separatedActivitiesType!

	// MARK: - Initializers

	init(coinInfoVM: CoinInfoViewModel) {
		self.coinInfoVM = coinInfoVM
		let flowLayout = UICollectionViewFlowLayout(scrollDirection: .vertical)
		super.init(frame: .zero, collectionViewLayout: flowLayout)
		configCollectionView()
		setupView()
		setUpStyle()
		setupBinding()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}

	// MARK: - Private Methods

	private func configCollectionView() {
		register(
			CoinInfoHeaderView.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: CoinInfoHeaderView.headerReuseID
		)
		register(
			ActivityHeaderView.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: ActivityHeaderView.viewReuseID
		)
		register(
			ActivityCell.self,
			forCellWithReuseIdentifier: ActivityCell.cellID
		)
		register(
			CoinInfoFooterview.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
			withReuseIdentifier: CoinInfoFooterview.footerReuseID
		)

		dataSource = self
		delegate = self
	}

	private func setupView() {
		setupRefreshControl()
	}

	private func setUpStyle() {
		backgroundColor = .Pino.background
		showsVerticalScrollIndicator = false
	}

	private func setupBinding() {
		let activityHelper = ActivityHelper()
		Publishers.Zip(coinInfoVM.$coinPortfolio, coinInfoVM.$coinHistoryList).sink { [weak self] _ in
			self?.separatedActivities = activityHelper
				.separateActivitiesByTime(activities: (self?.coinInfoVM.coinHistoryList)!)
			self?.reloadData()
		}.store(in: &cancellable)
	}

	private func setupRefreshControl() {
		indicatorStyle = .white
		historyRefreshContorl.tintColor = .Pino.green2
		historyRefreshContorl.addAction(UIAction(handler: { _ in
			self.refreshData()
		}), for: .valueChanged)
		refreshControl = historyRefreshContorl
	}

	private func refreshData() {
		coinInfoVM.refreshCoinInfoData { error in
			self.refreshControl?.endRefreshing()
			if let error {
				switch error {
				case .unreachable:
					Toast.default(title: self.coinInfoVM.connectionErrorToastMessage, style: .error)
						.show(haptic: .warning)
				default:
					Toast.default(title: self.coinInfoVM.requestFailedErrorToastMessage, style: .error)
						.show(haptic: .warning)
				}
			}
			self.hideSkeletonView()
		}
	}
}

// MARK: - CollectionView Flow Layout

extension ActivitiesCollectionView: UICollectionViewDelegateFlowLayout {
	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		sizeForItemAt indexPath: IndexPath
	) -> CGSize {
		CGSize(width: collectionView.frame.width, height: 72)
	}
}

// MARK: - CollectionView DataSource

extension ActivitiesCollectionView: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		let separatedActivitiesCount = separatedActivities.count
		if separatedActivitiesCount == 0 {
			return 1
		} else {
			return separatedActivitiesCount
		}
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch coinInfoVM.coinPortfolio.type {
		case .verified:
			if separatedActivities.indices.contains(section) {
				return separatedActivities[section].activities.count
			} else {
				return 0
			}
		case .unVerified:
			return 0
		case .position:
			return 0
		}
	}

	func collectionView(
		_ collectionView: UICollectionView,
		viewForSupplementaryElementOfKind kind: String,
		at indexPath: IndexPath
	) -> UICollectionReusableView {
		switch kind {
		case UICollectionView.elementKindSectionHeader:
			if indexPath.section == 0 {
				let coinInfoHeaderView = dequeueReusableSupplementaryView(
					ofKind: kind,
					withReuseIdentifier: CoinInfoHeaderView.headerReuseID,
					for: indexPath
				) as! CoinInfoHeaderView
				coinInfoHeaderView.coinInfoVM = coinInfoVM
				if coinInfoVM.coinPortfolio.showSkeletonLoading {
					coinInfoHeaderView.showSkeletonView()
				} else {
					coinInfoHeaderView.hideSkeletonView()
				}
				if separatedActivities.indices.contains(indexPath.section) {
					coinInfoHeaderView.activitiesTimeTitle = separatedActivities[indexPath.section].title
				}

				return coinInfoHeaderView
			} else {
				let activityHeaderView = dequeueReusableSupplementaryView(
					ofKind: kind,
					withReuseIdentifier: ActivityHeaderView.viewReuseID,
					for: indexPath
				) as! ActivityHeaderView
				activityHeaderView.titleText = separatedActivities[indexPath.section].title
				return activityHeaderView
			}
		case UICollectionView.elementKindSectionFooter:
			let coinInfoFooterView = dequeueReusableSupplementaryView(
				ofKind: UICollectionView.elementKindSectionFooter,
				withReuseIdentifier: CoinInfoFooterview.footerReuseID,
				for: indexPath
			) as! CoinInfoFooterview
			coinInfoFooterView.coinInfoVM = coinInfoVM

			return coinInfoFooterView
		default:
			fatalError("Unknown kind of coin info reusable view")
		}
	}

	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		referenceSizeForHeaderInSection section: Int
	) -> CGSize {
		let indexPath = IndexPath(row: 0, section: section)
		let headerView = self.collectionView(
			collectionView,
			viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
			at: indexPath
		)
		return headerView.systemLayoutSizeFitting(
			CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
			withHorizontalFittingPriority: .required,
			verticalFittingPriority: .fittingSizeLevel
		)
	}

	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		referenceSizeForFooterInSection section: Int
	) -> CGSize {
		switch coinInfoVM.coinPortfolio.type {
		case .verified:
			return CGSize(width: 0, height: 0)
		case .unVerified:
			return CGSize(width: collectionView.frame.width, height: 200)
		case .position:
			return CGSize(width: collectionView.frame.width, height: 200)
		}
	}

	func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		let coinHistoryCell = dequeueReusableCell(
			withReuseIdentifier: ActivityCell.cellID,
			for: indexPath
		) as! ActivityCell
		coinHistoryCell.activityCellVM = separatedActivities[indexPath.section].activities[indexPath.item]
		return coinHistoryCell
	}
}
