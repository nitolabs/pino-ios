//
//  ReceiveAssetViewController.swift
//  Pino-iOS
//
//  Created by Amir hossein kazemi seresht on 2/22/23.
//

import UIKit
import WebKit

class ReceiveAssetViewController: UIViewController {
	// MARK: - Private Properties

	private var receiveAssetView: ReceiveAssetView!
	private var receiveVM = ReceiveViewModel()
	private let addressQrCodeWebView = WKWebView()

	// MARK: - Public Properties

	public var homeVM: HomepageViewModel

	// MARK: - View Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func loadView() {
		setupView()
		setupNavigationBar()
	}

	override func viewDidAppear(_ animated: Bool) {
		if isBeingPresented || isMovingToParent {
			receiveAssetView.addressQrCodeImage = homeVM.walletInfo.address.generateQRCode(
				customHeight: 264,
				customWidth: 264
			)
		}
	}

	// MARK: - Initializers

	init(homeVM: HomepageViewModel) {
		self.homeVM = homeVM
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Private Methods

	private func setupView() {
		receiveAssetView = ReceiveAssetView(
			homeVM: homeVM,
			receiveVM: receiveVM
		)
		view = receiveAssetView
	}

	private func setupNavigationBar() {
		// Setup appreance for navigation bar
		setupPrimaryColorNavigationBar()
		// Setup navigation title
		setNavigationTitle(receiveVM.navigationTitleText)
		navigationItem.leftBarButtonItem = UIBarButtonItem(
			image: UIImage(named: receiveVM.navigationDismissButtonIconName),
			style: .plain,
			target: self,
			action: #selector(dismissVC)
		)
		navigationItem.rightBarButtonItem = UIBarButtonItem(
			image: UIImage(named: receiveVM.shareAddressButtonIconName),
			style: .plain,
			target: self,
			action: #selector(presentShareActivityViewController)
		)
	}

	@objc
	private func presentShareActivityViewController() {
		let sharedText = homeVM.walletInfo.address
		let shareItems = [sharedText]
		let activityVC = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
		present(activityVC, animated: true)
	}

	@objc
	private func dismissVC() {
		dismiss(animated: true)
	}
}
