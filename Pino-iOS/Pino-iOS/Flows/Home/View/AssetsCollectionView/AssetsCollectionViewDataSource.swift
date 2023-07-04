//
//  AssetsCollectionViewDataSource.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 12/24/22.
//

import UIKit

extension AssetsCollectionView: UICollectionViewDataSource {
	// MARK: - CollectionView DataSource Methods

	internal func numberOfSections(in collectionView: UICollectionView) -> Int {
		if homeVM.positionAssetsList?.isEmpty ?? true {
			return 1
		} else {
			return 2
		}
	}

	internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let homeSection = HomeSection(rawValue: section)
		if GlobalVariables.shared.selectedManageAssetsList.isEmpty { return 6 }
		switch homeSection {
		case .asset:
			return GlobalVariables.shared.selectedManageAssetsList.count
		case .position:
			return homeVM.positionAssetsList?.count ?? .zero
		case .none:
			return .zero
		}
	}

	internal func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		assetCollectionViewCell(indexPath: indexPath)
	}

	internal func collectionView(
		_ collectionView: UICollectionView,
		viewForSupplementaryElementOfKind kind: String,
		at indexPath: IndexPath
	) -> UICollectionReusableView {
		switch kind {
		case UICollectionView.elementKindSectionFooter:
			return homepageFooterView(kind: kind, indexPath: indexPath)!
		case UICollectionView.elementKindSectionHeader:
			return homepageHeaderView(kind: kind, indexPath: indexPath)!
		default:
			fatalError("Unexpected element kind")
		}
	}

	internal func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		referenceSizeForHeaderInSection section: Int
	) -> CGSize {
		let homeSection = HomeSection(rawValue: section)
		switch homeSection {
		case .asset:
			return CGSize(width: collectionView.frame.width, height: 212)
		case .position:
			return CGSize(width: collectionView.frame.width, height: 46)
		case .none:
			return .zero
		}
	}

	internal func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		referenceSizeForFooterInSection section: Int
	) -> CGSize {
		let homeSection = HomeSection(rawValue: section)
		switch homeSection {
		case .asset, .none:
			return .zero
		case .position:
			return CGSize(width: collectionView.frame.width, height: 100)
		}
	}

	// MARK: - Private Methods

	private func homepageHeaderView(kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
		let homeSection = HomeSection(rawValue: indexPath.section)
		switch homeSection {
		case .asset:
			// Wallet balance header
			let walletBalanceHeaderView = dequeueReusableSupplementaryView(
				ofKind: kind,
				withReuseIdentifier: AccountBalanceHeaderView.headerReuseID,
				for: indexPath
			) as! AccountBalanceHeaderView
			walletBalanceHeaderView.homeVM = homeVM
			walletBalanceHeaderView.sendButtonTappedClosure = sendButtonTappedClosure
			walletBalanceHeaderView.receiveButtonTappedClosure = receiveButtonTappedClosure
			walletBalanceHeaderView.portfolioPerformanceTapped = portfolioPerformanceTapped
			if homeVM.walletBalance == nil {
				walletBalanceHeaderView.showSkeletonView()
			} else {
				walletBalanceHeaderView.hideSkeletonView()
			}
			return walletBalanceHeaderView

		case .position:
			// Positon section header
			let positionHeaderView = dequeueReusableSupplementaryView(
				ofKind: kind,
				withReuseIdentifier: PositionHeaderView.headerReuseID,
				for: indexPath
			) as! PositionHeaderView
			positionHeaderView.title = "Position"
			return positionHeaderView

		case .none:
			return nil
		}
	}

	private func homepageFooterView(kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
		let manageAssetsFooterView = dequeueReusableSupplementaryView(
			ofKind: kind,
			withReuseIdentifier: ManageAssetsFooterView.footerReuseID,
			for: indexPath
		) as! ManageAssetsFooterView
		manageAssetsFooterView.title = "Manage assets"
		manageAssetsFooterView.manageAssetButton.addAction(UIAction(handler: { _ in
			self.manageAssetButtonTapped()
		}), for: .touchUpInside)
		return manageAssetsFooterView
	}

	private func assetCollectionViewCell(indexPath: IndexPath) -> UICollectionViewCell {
		let assetCell = dequeueReusableCell(
			withReuseIdentifier: AssetsCollectionViewCell.cellReuseID,
			for: indexPath
		) as! AssetsCollectionViewCell
		if !GlobalVariables.shared.selectedManageAssetsList.isEmpty {
			assetCell.hideSkeletonView()
			let homeSection = HomeSection(rawValue: indexPath.section)
			switch homeSection {
			case .asset:
				assetCell.assetVM = GlobalVariables.shared.selectedManageAssetsList[indexPath.row]
			case .position:
				assetCell.assetVM = AssetManager.shared.positionAssetsList?[indexPath.row]
			case .none: break
			}
		} else {
			assetCell.assetVM = nil
			assetCell.showSkeletonView()
		}
		return assetCell
	}

	enum HomeSection: Int, CaseIterable {
		case asset
		case position
	}
}
