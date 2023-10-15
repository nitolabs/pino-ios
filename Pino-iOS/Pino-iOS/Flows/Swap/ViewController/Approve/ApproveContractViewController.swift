//
//  ApproveContractViewController.swift
//  Pino-iOS
//
//  Created by Sobhan Eskandari on 8/15/23.
//

import Foundation
import UIKit

class ApproveContractViewController: UIViewController {
	// MARK: - Closures

	private var showConfirmVC: () -> Void

	// MARK: - Private Properties

	private let approveContractVM: ApproveContractViewModel!
	private var approveContractView: ApproveContractView!
	private var approveContractID: String!

	// MARK: - Initilizers

	init(approveContractID: String, showConfirmVC: @escaping () -> Void) {
		self.approveContractID = approveContractID
		self.approveContractVM = ApproveContractViewModel(contractId: approveContractID)
		self.showConfirmVC = showConfirmVC
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
		setupNavigationBar()
		setupView()
	}

	override func viewWillAppear(_ animated: Bool) {}

	// MARK: - Private Methods

	private func setupNavigationBar() {
		setupPrimaryColorNavigationBar()
		setNavigationTitle("Approve")
	}

	private func setupView() {
		approveContractView = ApproveContractView(approveContractVM: approveContractVM, onApproveTap: {
			self.showApproveLoadingPage()
		})

		view = approveContractView
	}

	private func showApproveLoadingPage() {
		approveContractVM.approveTokenUsageToPermit { approveTxHash in
			let approveLoadingVM = ApprovingLoadingViewModel(approveTxHash: approveTxHash)
			let approveLoadingVC = ApprovingLoadingViewController(
				showConfirmVC: {
					self.dismiss(animated: true) {
						self.showConfirmVC()
					}
				}, approveLoadingVM: approveLoadingVM
			)
			self.present(approveLoadingVC, animated: true)
		}
	}
}
