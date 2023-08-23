//
//  InvestmentRiskPerformanceView.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 8/22/23.
//

import UIKit

class InvestmentRiskPerformanceView: UIView {
	// MARK: - Private Properties

	private let contentStackView = UIStackView()
	private let assetInfoStackView = UIStackView()
	private let tokenStackView = UIStackView()
	private let tokenTitleStackView = UIStackView()
	private let tokenImageView = UIImageView()
	private let tokenNameLabel = UILabel()
	private let riskView = UIView()
	private let riskTitleLabel = UILabel()
	private let protocolCardView = UIView()
	private let protocolStackView = UIStackView()
	private let protocolImageStackView = UIStackView()
	private let protocolImageView = UIImageView()
	private let protocolTitleStackView = UIStackView()
	private let protocolNameLabel = UILabel()
	private let protocolTitleLabel = UILabel()
	private let protocolDescriptionLabel = UILabel()
	private let risksTitleLabel = UILabel()
	private let risksStackview = UIStackView()
	private let risksInfoCardView = UIView()
	private let risksInfoStackView = UIStackView()
	private let confirmButton = PinoButton(style: .active)
	private let closeButton = UIButton()

	private let investmentRiskVM: InvestmentRiskPerformanceViewModel
	private let viewDidDismiss: () -> Void

	// MARK: - Initializers

	init(investmentRiskVM: InvestmentRiskPerformanceViewModel, viewDidDismiss: @escaping () -> Void) {
		self.investmentRiskVM = investmentRiskVM
		self.viewDidDismiss = viewDidDismiss
		super.init(frame: .zero)
		setupView()
		setupStyle()
		setupContstraint()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Private Methods

	private func setupView() {
		addSubview(contentStackView)
		addSubview(confirmButton)
		addSubview(closeButton)
		contentStackView.addArrangedSubview(assetInfoStackView)
		contentStackView.addArrangedSubview(risksStackview)

		assetInfoStackView.addArrangedSubview(tokenStackView)
		assetInfoStackView.addArrangedSubview(protocolCardView)

		tokenStackView.addArrangedSubview(tokenTitleStackView)
		tokenStackView.addArrangedSubview(riskView)
		tokenTitleStackView.addArrangedSubview(tokenImageView)
		tokenTitleStackView.addArrangedSubview(tokenNameLabel)
		riskView.addSubview(riskTitleLabel)

		protocolCardView.addSubview(protocolStackView)
		protocolStackView.addArrangedSubview(protocolImageStackView)
		protocolStackView.addArrangedSubview(protocolDescriptionLabel)
		protocolImageStackView.addArrangedSubview(protocolImageView)
		protocolImageStackView.addArrangedSubview(protocolTitleStackView)
		protocolTitleStackView.addArrangedSubview(protocolNameLabel)
		protocolTitleStackView.addArrangedSubview(protocolTitleLabel)

		risksStackview.addArrangedSubview(risksTitleLabel)
		risksStackview.addArrangedSubview(risksInfoCardView)
		risksInfoCardView.addSubview(risksInfoStackView)
		setupRiskInfoView()

		closeButton.addAction(UIAction(handler: { _ in
			self.viewDidDismiss()
		}), for: .touchUpInside)

		confirmButton.addAction(UIAction(handler: { _ in
			self.viewDidDismiss()
		}), for: .touchUpInside)
	}

	private func setupStyle() {
		tokenNameLabel.text = investmentRiskVM.assetName
        riskTitleLabel.text = investmentRiskVM.investmentRiskName
        protocolTitleLabel.text = investmentRiskVM.protocolTitle
        protocolNameLabel.text = investmentRiskVM.protocolName
        protocolDescriptionLabel.text = investmentRiskVM.protocolDescription
        risksTitleLabel.text = investmentRiskVM.investmentRiskTitle
        confirmButton.title = investmentRiskVM.confirmButtonTitle
		protocolImageView.image = UIImage(named: investmentRiskVM.protocolImage)
		tokenImageView.kf.indicatorType = .activity
		tokenImageView.kf.setImage(with: investmentRiskVM.assetImage)
		closeButton.setImage(UIImage(systemName: "multiply"), for: .normal)

		tokenNameLabel.font = .PinoStyle.semiboldTitle2
		riskTitleLabel.font = .PinoStyle.mediumSubheadline
		protocolTitleLabel.font = .PinoStyle.mediumFootnote
		protocolNameLabel.font = .PinoStyle.semiboldTitle3
		protocolDescriptionLabel.font = .PinoStyle.mediumCallout
		risksTitleLabel.font = .PinoStyle.semiboldBody

		tokenNameLabel.textColor = .Pino.label
		riskTitleLabel.textColor = .Pino.label
		protocolTitleLabel.textColor = .Pino.secondaryLabel
		protocolNameLabel.textColor = .Pino.label
		protocolDescriptionLabel.textColor = .Pino.secondaryLabel
		risksTitleLabel.textColor = .Pino.label
		closeButton.tintColor = .Pino.secondaryLabel

		backgroundColor = .Pino.secondaryBackground
		protocolCardView.backgroundColor = .Pino.background
		riskView.backgroundColor = .Pino.lightRed
		closeButton.backgroundColor = .Pino.background

		contentStackView.axis = .vertical
		assetInfoStackView.axis = .vertical
		tokenStackView.axis = .vertical
		tokenTitleStackView.axis = .vertical
		protocolStackView.axis = .vertical
		protocolTitleStackView.axis = .vertical
		risksStackview.axis = .vertical
		risksInfoStackView.axis = .vertical

		tokenStackView.alignment = .center
		tokenTitleStackView.alignment = .center

		contentStackView.spacing = 48
		assetInfoStackView.spacing = 24
		tokenStackView.spacing = 6
		tokenTitleStackView.spacing = 16
		protocolStackView.spacing = 12
		protocolImageStackView.spacing = 6
		risksStackview.spacing = 8
		risksInfoStackView.spacing = 12

		protocolDescriptionLabel.numberOfLines = 0

		riskView.layer.cornerRadius = 14
		protocolCardView.layer.cornerRadius = 8
		risksInfoCardView.layer.cornerRadius = 8
		risksInfoCardView.layer.borderColor = UIColor.Pino.background.cgColor
		risksInfoCardView.layer.borderWidth = 1
		closeButton.layer.cornerRadius = 15
	}

	private func setupContstraint() {
		contentStackView.pin(
			.horizontalEdges(padding: 16),
			.top(padding: 66)
		)
		protocolStackView.pin(
			.verticalEdges(padding: 14),
			.horizontalEdges(padding: 12)
		)
		risksInfoStackView.pin(
			.allEdges(padding: 12)
		)
		tokenImageView.pin(
			.fixedWidth(72),
			.fixedHeight(72)
		)
		protocolImageView.pin(
			.fixedWidth(40),
			.fixedHeight(40)
		)
		riskTitleLabel.pin(
			.horizontalEdges(padding: 12),
			.centerY
		)
		riskView.pin(
			.fixedHeight(28)
		)
		confirmButton.pin(
			.bottom(to: layoutMarginsGuide, padding: 8),
			.horizontalEdges(padding: 16)
		)
		closeButton.pin(
			.fixedWidth(30),
			.fixedHeight(30),
			.trailing(padding: 16),
			.top(padding: 24)
		)
	}

	private func setupRiskInfoView() {
        for riskInfo in investmentRiskVM.risksInfo {
			let riskInfoView = riskInfoItemView()
            riskInfoView.riskInfo = riskInfo.titel
            riskInfoView.riskColor = riskInfo.color
			risksInfoStackView.addArrangedSubview(riskInfoView)
		}
	}
}
