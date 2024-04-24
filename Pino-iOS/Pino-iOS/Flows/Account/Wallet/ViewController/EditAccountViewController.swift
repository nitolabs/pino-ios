//
//  EditAccountViewController.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 2/14/23.
//

import Combine
import UIKit

class EditAccountViewController: UIViewController {
	// MARK: Private Properties

	private let accountsVM: AccountsViewModel
	private let editAccountVM: EditAccountViewModel
	private let hapticManager = HapticManager()
	private var cancellables = Set<AnyCancellable>()
	private var editAccountView: EditAccountView!

	// MARK: Initializers

	init(accountsVM: AccountsViewModel, editAccountVM: EditAccountViewModel) {
		self.accountsVM = accountsVM
		self.editAccountVM = editAccountVM
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
		setupBindings()
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent, transitionCoordinator?.isInteractive == false {
            // code here
            hapticManager.run(type: .lightImpact)
        }
    }

	// MARK: - Private Methods

	private func setupView() {
		editAccountView = EditAccountView(
			editAccountVM: editAccountVM,
			openAvatarPage: { [weak self] in
				self?.openAvatarPage()
			},
			openRemoveAccount: { [weak self] in
				self?.openRemoveAccountPage()
			},
			openRevealPrivateKey: { [weak self] in
				self?.openRevealPrivateKey()
			},
			openEditAccountNameClosure: { [weak self] in
				self?.openEditAccountName()
			}
		)
		view = editAccountView
	}

	private func setupNavigationBar() {
		setupPrimaryColorNavigationBar()
		// Setup title view
		setNavigationTitle(editAccountVM.pageTitle)
		// Setup add asset button
		navigationItem.rightBarButtonItem = UIBarButtonItem(
			title: editAccountVM.doneButtonText,
			style: .plain,
			target: self,
			action: #selector(saveChanges)
		)
	}

	private func setupBindings() {
		accountsVM.$accountsList.sink { wallets in
			guard let wallets else { return }
			if wallets.count > 1 {
				self.editAccountVM.isLastAccount = false
			} else {
				self.editAccountVM.isLastAccount = true
			}
		}.store(in: &cancellables)
	}

	@objc
	private func saveChanges() {
		hapticManager.run(type: .mediumImpact)
		dismiss(animated: true)
	}

	private func openAvatarPage() {
		hapticManager.run(type: .mediumImpact)
		let avatarVM = AvatarViewModel(selectedAvatar: editAccountVM.selectedAccount.profileImage)
		let changeAvatarVC = ChangeAvatarViewController(avatarVM: avatarVM) { [weak self] avatarName in
			self?.editAccountAvatar(newAvatar: avatarName)
		}
		navigationController?.pushViewController(changeAvatarVC, animated: true)
	}

	private func openRemoveAccountPage() {
		hapticManager.run(type: .heavyImpact)
		let removeAccountVC = RemoveAccountViewController()
		present(removeAccountVC, animated: true)
		removeAccountVC.walletIsDeleted = {
			self.removeAccount()
		}
	}

	private func removeAccount() {
		accountsVM.removeAccount(editAccountVM.selectedAccount).catch { error in
			self.showErrorToast(error)
		}
		navigationController!.popViewController(animated: true)
	}

	private func openRevealPrivateKey() {
		hapticManager.run(type: .selectionChanged)
		let revealVM = RevealPrivateKeyViewModel(selectedAccount: editAccountVM.selectedAccount)
		let revaelPrivateKeyVC = RevealPrivateKeyViewController(revealPrivateKeyVM: revealVM)
		navigationController?.pushViewController(revaelPrivateKeyVC, animated: true)
	}

	private func openEditAccountName() {
		hapticManager.run(type: .selectionChanged)
		let editWalletNameVC = EditAccountNameViewController(
			selectedAccountVM: editAccountVM.selectedAccount,
			accountsVM: accountsVM
		) { [weak self] walletName in
			self?.editAccountName(newName: walletName)
		}
		navigationController?.pushViewController(editWalletNameVC, animated: true)
	}

	private func editAccountName(newName: String) {
		let edittedAccount = accountsVM.editAccount(account: editAccountVM.selectedAccount, newName: newName)
		editAccountVM.selectedAccount = edittedAccount
	}

	private func editAccountAvatar(newAvatar: String) {
		let edittedAccount = accountsVM.editAccount(account: editAccountVM.selectedAccount, newAvatar: newAvatar)
		editAccountVM.selectedAccount = edittedAccount
	}

	private func showErrorToast(_ error: Error) {
		if let error = error as? ToastError {
			Toast.default(title: error.toastMessage, style: .error).show()
		}
	}
}
