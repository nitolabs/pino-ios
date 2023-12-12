//
//  IntroCollectionView.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 11/20/22.
//
// swiftlint: disable force_cast

import UIKit

class IntroCollectionView: UICollectionView {
	// MARK: Public Properties

	public var introContents: [IntroModel] = [] {
		didSet {
			reloadData()
		}
	}

	public var pageDidChange: ((Int) -> Void)?

	// MARK: Initializers

	convenience init() {
		// Set flow layout for collection view
		let flowLayout = UICollectionViewFlowLayout()
		flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
		flowLayout.scrollDirection = .horizontal
		self.init(frame: .zero, collectionViewLayout: flowLayout)

		configCollectionView()
		setupStyle()
	}

	override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		super.init(frame: frame, collectionViewLayout: layout)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}

	// MARK: Private Methods

	private func configCollectionView() {
        register(IntroCollectionViewCell.self, forCellWithReuseIdentifier: IntroCollectionViewCell.cellReuseID)
		register(IntroAnimationCollectionViewCell.self, forCellWithReuseIdentifier: IntroAnimationCollectionViewCell.cellReuseID)
		dataSource = self
		delegate = self
		isPagingEnabled = true
		showsHorizontalScrollIndicator = false
	}

	private func setupStyle() {
		backgroundColor = .Pino.secondaryBackground
	}
}

// MARK: Collection View DataSource

extension IntroCollectionView: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		introContents.count
	}

	func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		let index = indexPath.item
        if index == 0 {
            let introAnimationCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: IntroAnimationCollectionViewCell.cellReuseID,
                for: indexPath
            ) as! IntroAnimationCollectionViewCell
            introAnimationCell.introModel = introContents[index]
            return introAnimationCell
        } else {
            let introCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: IntroCollectionViewCell.cellReuseID,
                for: indexPath
            ) as! IntroCollectionViewCell
            introCell.introModel = introContents[index]
            return introCell
        }
		
	}
}

// MARK: Collection View Delegate

extension IntroCollectionView: UICollectionViewDelegate {
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		// The page control in the parent view needs it to update current page
		if let pageDidChange {
			// Get the current page based on the scroll offset
			let page = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
			pageDidChange(page)
		}
	}
}

// MARK: Collection View Flow Layout

extension IntroCollectionView: UICollectionViewDelegateFlowLayout {
	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		sizeForItemAt indexPath: IndexPath
	) -> CGSize {
        if indexPath.row == 0 {
            CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        } else {
            CGSize(width: collectionView.frame.width, height: 480)
        }
	}

	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		minimumLineSpacingForSectionAt section: Int
	) -> CGFloat {
		0
	}
}
