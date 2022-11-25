//
//  PinoButtonStyle.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 11/9/22.
//

import UIKit

// MARK: - PinoButton Style

extension PinoButton {
	// Specifies a visual theme of the button
	public struct Style: Equatable {
		public let titleColor: UIColor
		public let backgroundColor: UIColor
		public let borderColor: UIColor?
	}
}

// MARK: - Custom Button Styles

extension PinoButton.Style {
	public static let active = PinoButton.Style(
		titleColor: .Pino.white,
		backgroundColor: .Pino.primary,
		borderColor: .Pino.clear
	)

	public static let deactive = PinoButton.Style(
		titleColor: .Pino.gray2,
		backgroundColor: .Pino.gray5,
		borderColor: .Pino.clear
	)

	public static let success = PinoButton.Style(
		titleColor: .Pino.white,
		backgroundColor: .Pino.successGreen,
		borderColor: .Pino.clear
	)

	public static let delete = PinoButton.Style(
		titleColor: .Pino.white,
		backgroundColor: .Pino.ErrorRed,
		borderColor: .Pino.clear
	)

	public static let secondary = PinoButton.Style(
		titleColor: .Pino.primary,
		backgroundColor: .Pino.clear,
		borderColor: .Pino.primary
	)

	public static let loading = PinoButton.Style(
		titleColor: .Pino.white,
		backgroundColor: .Pino.green3,
		borderColor: .Pino.clear
	)
}
