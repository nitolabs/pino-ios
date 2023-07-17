//
//  ActivityDetailsHeaderView.swift
//  Pino-iOS
//
//  Created by Amir hossein kazemi seresht on 7/11/23.
//

import UIKit

class ActivityDetailsHeaderView: UIView {
	// MARK: - Public Properties

	public var activityDetailsVM: ActivityDetailsViewModel

	// MARK: - Private Properties

	private var activitySwapHeaderView: ActivitySwapHeaderView!
	private let cardView = PinoContainerCard()
	private let defaultStackView = UIStackView()
	private let defaultImageView = UIImageView()
	private let defaultTitleLabel = PinoLabel(style: .title, text: "")

	// MARK: - Initializers

	init(activityDetailsVM: ActivityDetailsViewModel) {
		self.activityDetailsVM = activityDetailsVM

		super.init(frame: .zero)

		setupView()
		setupStyles()
		setupConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Private Methods

	private func setupView() {
		defaultStackView.addArrangedSubview(defaultImageView)
		defaultStackView.addArrangedSubview(defaultTitleLabel)

		cardView.addSubview(defaultStackView)
		addSubview(cardView)
	}

	private func setupStyles() {
		defaultStackView.axis = .vertical
		defaultStackView.alignment = .center
		defaultStackView.spacing = 16

		defaultTitleLabel.font = .PinoStyle.semiboldTitle2
		defaultTitleLabel.text = activityDetailsVM.assetAmountTitle ?? ""
		defaultTitleLabel.numberOfLines = 0

		defaultImageView
			.image = UIImage(named: activityDetailsVM.assetIconName ?? activityDetailsVM.unVerifiedAssetIconName)
	}

	private func setupConstraints() {
		cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 126).isActive = true

		cardView.pin(.allEdges(padding: 0))
		defaultStackView.pin(.verticalEdges(padding: 16), .horizontalEdges(padding: 14))
		defaultImageView.pin(.fixedWidth(50), .fixedHeight(50))
	}
}
