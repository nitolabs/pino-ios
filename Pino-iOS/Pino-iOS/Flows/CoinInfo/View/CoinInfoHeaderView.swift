//
//  CoinInfoHeaderView.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 2/17/23.
//

import Combine
import UIKit

class CoinInfoHeaderView: UICollectionReusableView {
	// MARK: - Private Properties

	private var contentStackView = UIStackView()
	private var contentView = UIView()
	private var userCoinInfoStackView = UIStackView()
	private var separatorLineView = UIView()
	private var userPortfolioStackView = UIStackView()

	private var coinInfoStackView = UIStackView()
	private var amountStackView = UIStackView()
	private var amountLabel = UILabel()
	private var assetsIcon = UIImageView()
	private var assetsTitleLabel = UILabel()
	private var userAmountLabel = UILabel()
	private var volatilityRateStackView = UIStackView()
	private var volatilityRateIcon = UIImageView()
	private var volatilityRateLabel = UILabel()

	private var investStackView = UIStackView()
	private var investInfoStackView = UIStackView()
	private var investTitleLabel = UILabel()
	private var investInfoButtton = UIButton()
	private var investLabel = UILabel()

	private var collateralStackView = UIStackView()
	private var collateralInfoStackView = UIStackView()
	private var collateralTitleLabel = UILabel()
	private var collateralInfoButton = UIButton()
	private var collateralLabel = UILabel()

	private var borrowStackView = UIStackView()
	private var borrowInfoStackView = UIStackView()
	private var borrowTitleLabel = UILabel()
	private var borrowInfoButton = UIButton()
	private var borrowLabel = UILabel()

	private var recentHistoryTitle = UILabel()

	private var cancellables = Set<AnyCancellable>()

	// MARK: - public properties

	public static let headerReuseID = "coinInfoHeader"

	public var coinInfoVM: CoinInfoViewModel! {
		didSet {
			setupView()
			setupStyle()
			setupBinding()
			setupConstraint()
		}
	}

	// MARK: - Private Methods

	private func setupView() {
		backgroundColor = .Pino.background
		contentView.addSubview(contentStackView)
		contentStackView.addArrangedSubview(userCoinInfoStackView)
		contentStackView.addArrangedSubview(separatorLineView)
		contentStackView.addArrangedSubview(userPortfolioStackView)
		userCoinInfoStackView.addArrangedSubview(amountStackView)
		amountStackView.addArrangedSubview(amountLabel)
		amountStackView.addArrangedSubview(volatilityRateStackView)
		volatilityRateStackView.addArrangedSubview(volatilityRateIcon)
		volatilityRateStackView.addArrangedSubview(volatilityRateLabel)
		userCoinInfoStackView.addArrangedSubview(coinInfoStackView)
		coinInfoStackView.addArrangedSubview(assetsIcon)
		coinInfoStackView.addArrangedSubview(assetsTitleLabel)
		coinInfoStackView.addArrangedSubview(userAmountLabel)

		userPortfolioStackView.addArrangedSubview(investStackView)
		userPortfolioStackView.addArrangedSubview(collateralStackView)
		userPortfolioStackView.addArrangedSubview(borrowStackView)

		investStackView.addArrangedSubview(investInfoStackView)
		investStackView.addArrangedSubview(investLabel)

		investInfoStackView.addArrangedSubview(investTitleLabel)
		investInfoStackView.addArrangedSubview(investInfoButtton)

		collateralStackView.addArrangedSubview(collateralInfoStackView)
		collateralStackView.addArrangedSubview(collateralLabel)

		collateralInfoStackView.addArrangedSubview(collateralTitleLabel)
		collateralInfoStackView.addArrangedSubview(collateralInfoButton)

		borrowStackView.addArrangedSubview(borrowInfoStackView)
		borrowStackView.addArrangedSubview(borrowLabel)

		borrowInfoStackView.addArrangedSubview(borrowTitleLabel)
		borrowInfoStackView.addArrangedSubview(borrowInfoButton)

		addSubview(contentView)
		addSubview(recentHistoryTitle)
	}

	private func setupStyle() {
		recentHistoryTitle.text = "Recent history"
		investTitleLabel.text = "Invest"
		collateralTitleLabel.text = "Collateral"
		borrowTitleLabel.text = "Borrow"

		contentView.backgroundColor = .Pino.secondaryBackground
		separatorLineView.backgroundColor = .Pino.gray5

		recentHistoryTitle.textColor = .Pino.label
		amountLabel.textColor = .secondaryLabel
		userAmountLabel.textColor = .secondaryLabel
		assetsTitleLabel.textColor = .Pino.label

		recentHistoryTitle.font = .PinoStyle.mediumSubheadline
		amountLabel.font = .PinoStyle.mediumSubheadline
		userAmountLabel.font = .PinoStyle.mediumCallout
		volatilityRateLabel.font = .PinoStyle.mediumSubheadline
		assetsTitleLabel.font = .PinoStyle.semiboldTitle2

		contentStackView.axis = .vertical
		userCoinInfoStackView.axis = .vertical
		amountStackView.axis = .horizontal
		volatilityRateStackView.axis = .horizontal
		coinInfoStackView.axis = .vertical
		userPortfolioStackView.axis = .vertical

		coinInfoStackView.spacing = 13
		contentStackView.spacing = 30
		userCoinInfoStackView.spacing = -20
		userPortfolioStackView.spacing = 25

		coinInfoStackView.alignment = .center

		coinInfoStackView.distribution = .fill
		userPortfolioStackView.distribution = .fillEqually
		contentStackView.distribution = .fill

		[investInfoButtton, borrowInfoButton, collateralInfoButton].forEach {
			$0.setImage(UIImage(named: "Info-Circle, error"), for: .normal)
			$0.tintColor = .Pino.gray3
		}

		[investStackView, collateralStackView, borrowStackView].forEach {
			$0.axis = .horizontal
			$0.spacing = 8
			$0.distribution = .equalCentering
		}

		[investInfoStackView, collateralInfoStackView, borrowInfoStackView].forEach {
			$0.axis = .horizontal
			$0.spacing = 5
			$0.alignment = .center
		}

		[investTitleLabel, collateralTitleLabel, borrowTitleLabel].forEach {
			$0.font = .PinoStyle.mediumBody
			$0.textColor = .Pino.secondaryLabel
		}

		[investLabel, collateralLabel, borrowLabel].forEach {
			$0.font = .PinoStyle.mediumBody
			$0.textColor = .Pino.label
		}

		contentView.layer.cornerRadius = 10
	}

	private func setupBinding() {
		coinInfoVM.$coinPortfolio.sink { [weak self] coinPortfolio in
			guard let coinPortfolio = coinPortfolio else { return }
			self?.amountLabel.text = coinPortfolio.coinAmount
			self?.assetsIcon.image = UIImage(named: coinPortfolio.assetImage)
			self?.assetsTitleLabel.text = coinPortfolio.name
			self?.userAmountLabel.text = coinPortfolio.userAmount
			self?.volatilityRateLabel.text = coinPortfolio.volatilityRate
			self?.investLabel.text = coinPortfolio.investAmount
			self?.collateralLabel.text = coinPortfolio.callateralAmount
			self?.borrowLabel.text = coinPortfolio.borrowAmount
		}.store(in: &cancellables)
	}

	private func setupConstraint() {
		contentView.pin(
			.top(padding: 32),
			.horizontalEdges(padding: 16)
		)
		recentHistoryTitle.pin(
			.relative(.top, 24, to: contentView, .bottom),
			.bottom(padding: 8),
			.horizontalEdges(padding: 16)
		)
		contentStackView.pin(
			.verticalEdges(padding: 16),
			.horizontalEdges(padding: 14)
		)

		assetsIcon.pin(
			.fixedHeight(70),
			.fixedWidth(70)
		)
		separatorLineView.pin(
			.fixedHeight(1)
		)

		[investInfoButtton, collateralInfoButton, borrowInfoButton].forEach {
			$0.pin(
				.fixedHeight(20),
				.fixedWidth(20)
			)
		}
	}
}
