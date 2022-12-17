//
//  IntroCollectionViewCell.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 11/20/22.
//

import UIKit

public class IntroCollectionViewCell: UICollectionViewCell {
	// MARK: Private Properties

	private let contentStackView = UIStackView()
	private let introImage = UIImageView()
	private let titleStackView = UIStackView()
	private let introTitle = PinoLabel(style: .title, text: nil)
	private let introDescription = PinoLabel(style: .description, text: nil)

	// MARK: Public Properties

	public static let cellReuseID = "introCell"
	public var introModel: IntroModel! {
		didSet {
			setupView()
			setupStyle()
			setupConstraint()
			setImageCornerRadius()
		}
	}
}

extension IntroCollectionViewCell {
	// MARK: UI Methods

	private func setupView() {
		contentView.addSubview(contentStackView)
		contentStackView.addArrangedSubview(introImage)
		contentStackView.addArrangedSubview(titleStackView)
		titleStackView.addArrangedSubview(introTitle)
		titleStackView.addArrangedSubview(introDescription)
	}

	private func setupStyle() {
		contentStackView.axis = .vertical
		contentStackView.spacing = 32
		contentStackView.alignment = .center

		titleStackView.axis = .vertical
		titleStackView.spacing = 20
		titleStackView.alignment = .center

		introImage.image = UIImage(named: introModel.image)
		introImage.backgroundColor = .Pino.background

		introTitle.text = introModel.title
		introDescription.text = introModel.description
		introDescription.textAlignment = .center
	}

	private func setupConstraint() {
		contentStackView.pin(
			.horizontalEdges(padding: 48),
			.verticalEdges
		)
		introImage.pin(
			.relative(.width, 0, to: introImage, .height)
		)
	}

	private func setImageCornerRadius() {
		layoutIfNeeded()
		introImage.layer.cornerRadius = introImage.frame.height / 2
	}
}
