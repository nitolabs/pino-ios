//
//  EnterPasscodeViewController.swift
//  Pino-iOS
//
//  Created by Amir hossein kazemi seresht on 4/5/23.
//

import UIKit

class UnlockAppViewController: UIViewController {
	// MARK: - Public Properties

	public var onSuccessUnlock: () -> Void

	// MARK: - Private Properties

	private var unlockAppVM: UnlockAppViewModel!
	private var managePasscodeView: ManagePasscodeView!

	// MARK: - View Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func loadView() {
		setupView()
		managePasscodeView?.passDotsView.becomeFirstResponder()
	}

	// MARK: - Initializers

	init(onSuccessUnlock: @escaping () -> Void) {
		self.onSuccessUnlock = onSuccessUnlock
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Private Methods

	private func setupView() {
		setupUnlockAppVM()
		managePasscodeView = ManagePasscodeView(managePassVM: unlockAppVM)
		managePasscodeView.onSuccessUnlockClosure = { [weak self] in
			self?.onSuccessUnlock()
		}
		checkIfUserHasFaceID()
		managePasscodeView.isUnlockMode = true
		view = managePasscodeView
	}

	private func setupUnlockAppVM() {
		unlockAppVM = UnlockAppViewModel(
			onClearError: { [weak self] in
				self?.managePasscodeView.hideError()
			}, onErrorHandling: { [weak self] error in
				switch error {
				case .dontMatch:
					self?.managePasscodeView.passDotsView.showErrorState()
					self?.managePasscodeView.showErrorWith(text: (self?.unlockAppVM.dontMatchErrorText)!)
				case .getPasswordFailed:
					fatalError("Failed to get user passcode")
				case .emptyPasscode:
					fatalError("Passcode is empty")
				}
			}, onSuccessUnlock: { [weak self] in
				self?.onSuccessLogin()
			}
		)
	}

	private func checkIfUserHasFaceID() {
		// check if user has face id

		managePasscodeView.hasFaceIDMode = true
	}

	private func onSuccessLogin() {
		onSuccessUnlock()
		dismiss(animated: true)
	}
}
