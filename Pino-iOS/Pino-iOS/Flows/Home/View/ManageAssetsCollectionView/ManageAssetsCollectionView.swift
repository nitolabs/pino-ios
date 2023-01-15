//
//  ManageAssetsCollectionView.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 1/14/23.
//

import UIKit

class ManageAssetsCollectionView: UICollectionView {
	// MARK: - Public Properties

	public var homeVM: HomepageViewModel!

	// MARK: Initializers

	init(homeVM: HomepageViewModel) {
		self.homeVM = homeVM
		// Set flow layout for collection view
		let flowLayout = UICollectionViewFlowLayout()
		flowLayout.minimumLineSpacing = 0
		flowLayout.scrollDirection = .vertical
		flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
		super.init(frame: .zero, collectionViewLayout: flowLayout)

		configCollectionView()
		setupStyle()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}

	// MARK: Private Methods

	private func configCollectionView() {
		register(
			ManageAssetCell.self,
			forCellWithReuseIdentifier: ManageAssetCell.cellReuseID
		)

		dataSource = self
		delegate = self
	}

	private func setupStyle() {
		backgroundColor = .Pino.background
		showsVerticalScrollIndicator = false
	}
}

// MARK: - CollectionView DataSource

extension ManageAssetsCollectionView: UICollectionViewDataSource {
	internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		homeVM.manageAssetsList.count
	}

	internal func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		let assetCell = dequeueReusableCell(
			withReuseIdentifier: ManageAssetCell.cellReuseID,
			for: indexPath
		) as! ManageAssetCell
		assetCell.assetVM = homeVM.manageAssetsList[indexPath.item]
		return assetCell
	}
}

// MARK: Collection Delegate

extension ManageAssetsCollectionView: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let manageAssetCell = cellForItem(at: indexPath) as! ManageAssetCell
		manageAssetCell.toggleAssetSwitch()
		homeVM.manageAssetsList[indexPath.item].toggleIsSelected()
	}
}

// MARK: Collection View Flow Layout

extension ManageAssetsCollectionView: UICollectionViewDelegateFlowLayout {
	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		sizeForItemAt indexPath: IndexPath
	) -> CGSize {
		CGSize(width: collectionView.frame.width, height: 72)
	}

	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		minimumLineSpacingForSectionAt section: Int
	) -> CGFloat {
		1
	}
}
