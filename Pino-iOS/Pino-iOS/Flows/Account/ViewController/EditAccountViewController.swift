//
//  EditAccountViewController.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 2/14/23.
//

import UIKit

class EditAccountViewController: UIViewController {
	// MARK: Private Properties

	private let walletVM: WalletsViewModel
	private let selectedWallet: WalletInfoViewModel
	private var editAccountView: EditAccountView!

	// MARK: Initializers

	init(walletVM: WalletsViewModel, selectedWallet: WalletInfoViewModel) {
		self.walletVM = walletVM
		self.selectedWallet = selectedWallet
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func loadView() {
		setupView()
		setupNavigationBar()
	}

	// MARK: - Private Methods

	private func setupView() {
		editAccountView = EditAccountView(walletVM: selectedWallet, newAvatarTapped: {
			self.openAvatarPage()
		})
		view = editAccountView
	}

	private func setupNavigationBar() {
		// Setup title view
		setNavigationTitle("Change avatar")
		// Setup add asset button
		navigationItem.rightBarButtonItem = UIBarButtonItem(
			title: "Done",
			style: .plain,
			target: self,
			action: #selector(saveChanges)
		)
		let textAttributes = [
			NSAttributedString.Key.foregroundColor: UIColor.Pino.white,
			NSAttributedString.Key.font: UIFont.PinoStyle.semiboldBody!,
		]
		navigationItem.rightBarButtonItem?.setTitleTextAttributes(textAttributes, for: .normal)
	}

	@objc
	private func saveChanges() {
		if let newName = editAccountView.walletNameTextFieldView.getText() {
			let newAvatar = editAccountView.newAvatar
			let builder = WalletBuilder(walletInfo: selectedWallet)
			if selectedWallet.name != newName {
				builder.setProfileName(newName)
			}
			if selectedWallet.profileImage != newAvatar {
				builder.setProfileImage(newAvatar)
			}
			if selectedWallet.profileColor != newAvatar {
				builder.setProfileColor(newAvatar)
			}
			walletVM.editWallet(newWallet: builder.build())
			navigationController!.popViewController(animated: true)
		} else {
			editAccountView.walletNameTextFieldView.style = .error
		}
	}

	private func openAvatarPage() {
		let avatarVM = AvatarViewModel(selectedAvatar: selectedWallet.profileImage)
		let changeAvatarVC = ChangeAvatarViewController(avatarVM: avatarVM) { avatarName in
			self.editAccountView.newAvatar = avatarName
		}
		navigationController?.pushViewController(changeAvatarVC, animated: true)
	}
}
