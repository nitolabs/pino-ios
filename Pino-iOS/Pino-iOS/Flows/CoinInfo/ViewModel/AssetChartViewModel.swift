//
//  AssetChartViewModel.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 2/25/23.
//
import DGCharts
import Foundation

struct AssetChartViewModel {
	// MARK: - Public Properties

	public let chartDataVM: [AssetChartDataViewModel]
	public var dateFilter: ChartDateFilter

	public var chartDataEntry: [ChartDataEntry] {
		chartDataVM.map {
			ChartDataEntry(x: $0.date!.timeIntervalSinceNow, y: $0.networth.doubleValue)
		}
	}

	public var balance: String {
		chartDataVM.last?.networth.decimalString.currencyFormatting ?? "0.0"
	}

	public var volatilityPercentage: String {
		formattedVolatility(valueChangePercentage())
	}

	public var volatilityType: AssetVolatilityType {
		volatilityType(valueChangePercentage())
	}

	public var chartDate: String {
		let chartDateBuilder = ChartDateBuilder(dateFilter: dateFilter)
		return chartDateBuilder.timeFrame()
	}

	init(chartDataVM: [AssetChartDataViewModel], dateFilter: ChartDateFilter) {
		self.chartDataVM = chartDataVM
		self.dateFilter = dateFilter
	}

	// MARK: - Private Methods

	private func valueChangePercentage() -> Double {
		if chartDataEntry.count > 1 {
			let valueChangePercentage = valueChangePercentage(
				pointValue: chartDataEntry[chartDataEntry.count - 1].y,
				previousValue: chartDataEntry[0].y
			)
			return valueChangePercentage
		} else {
			return 0
		}
	}

	// MARK: - Public Methods

	public func valueChangePercentage(pointValue: Double, previousValue: Double?) -> Double {
		if let previousValue, previousValue != 0 {
			let changePercentage = ((pointValue - previousValue) / previousValue) * 100
			return changePercentage.roundToPlaces(2)
		} else {
			return 0
		}
	}

	public func formattedVolatility(_ valueChangePercentage: Double) -> String {
		let volatilityType = volatilityType(valueChangePercentage)
		return "\(volatilityType.prependSign)\(abs(valueChangePercentage))%"
	}

	public func volatilityType(_ valueChangePercentage: Double) -> AssetVolatilityType {
		if valueChangePercentage > 0 {
			return .profit
		} else if valueChangePercentage < 0 {
			return .loss
		} else {
			return .none
		}
	}

	public func selectedDate(timeStamp: Double) -> String {
		let date = Date(timeIntervalSinceNow: timeStamp)
		let chartDateBuilder = ChartDateBuilder(dateFilter: dateFilter)
		return chartDateBuilder.selectedDate(date: date)
	}
}
