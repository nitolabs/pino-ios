//
//  SecretPhraseCollectionView.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 11/13/22.
//
// swiftlint: disable force_cast

import UIKit

class SecretPhraseCollectionView: UICollectionView {
	// MARK: Public Properties

	public var seedPhrase: [SeedPhrase] = [] {
		didSet {
			reloadData()
		}
	}

	public var defultStyle = SecretPhraseCell.SeedPhraseStyle.defaultStyle
	public var wordSelected: ((SeedPhrase) -> Void)?

	// MARK: Initializers

	convenience init() {
		// Set flow layout for collection view
		let flowLayout = SecretPhraseCenteredFlowLayout()
		flowLayout.minimumInteritemSpacing = 8
		flowLayout.minimumLineSpacing = 8
		flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
		self.init(frame: .zero, collectionViewLayout: flowLayout)

		registerCell()
		setupStyle()
	}

	override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		super.init(frame: frame, collectionViewLayout: layout)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}

	// MARK: Private Methods

	private func registerCell() {
		register(SecretPhraseCell.self, forCellWithReuseIdentifier: "secretPhrase")
		dataSource = self
		delegate = self
	}

	private func setupStyle() {
		backgroundColor = .Pino.clear
	}

	// MARK: UI Overrides

	override func layoutSubviews() {
		super.layoutSubviews()
		if !__CGSizeEqualToSize(bounds.size, intrinsicContentSize) {
			invalidateIntrinsicContentSize()
		}
	}

	override var intrinsicContentSize: CGSize {
		contentSize
	}
}

// MARK: Collection View DataSource

extension SecretPhraseCollectionView: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		seedPhrase.count
	}

	func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		let index = indexPath.item
		let secretPhraseCell = collectionView.dequeueReusableCell(
			withReuseIdentifier: "secretPhrase",
			for: indexPath
		) as! SecretPhraseCell
		secretPhraseCell.seedPhrase = seedPhrase[index]
        secretPhraseCell.seedPhraseStyle = defultStyle
		return secretPhraseCell
	}
}

// MARK: Collection View Delegate

extension SecretPhraseCollectionView: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let index = indexPath.item
		if let wordSelected = wordSelected {
			wordSelected(seedPhrase[index])
		}
	}
}
