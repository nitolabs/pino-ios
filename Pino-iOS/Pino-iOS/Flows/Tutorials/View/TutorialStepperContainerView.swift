//
//  TutorialStepperView.swift
//  Pino-iOS
//
//  Created by Sobhan Eskandari on 11/27/23.
//

import UIKit
import Combine

class TutorialStepperContainerView: UICollectionView {
	
    // MARK: - Public Properties

	// MARK: - Private Properties
    private let tutorialVM: TutorialContainerViewModel!
    private var cancellables = Set<AnyCancellable>()

	private func configureCollectionView() {
		delegate = self
		dataSource = self

		register(TutorialStepperCell.self, forCellWithReuseIdentifier: TutorialStepperCell.cellReuseID)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.setupBindings()
        }
	}

	// MARK: - Initializers

    init(tutorialVM: TutorialContainerViewModel) {
        self.tutorialVM = tutorialVM
        
		let collectionViewFlowLayout = UICollectionViewFlowLayout(scrollDirection: .horizontal)
		super.init(frame: .zero, collectionViewLayout: collectionViewFlowLayout)

		configureCollectionView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    // MARK: - Private Methods

    private func setupBindings() {
        tutorialVM.$currentIndex.sink { [self] index in
            print("Index:\(index)")
            print("---------------------------------")
            
            for x in index..<tutorialVM.tutorials.count {
                let cell = self.cellForItem(at: .init(row: x, section: 0)) as! TutorialStepperCell
                cell.resetProgress()
            }
            
            let cell = self.cellForItem(at: .init(row: index, section: 0)) as! TutorialStepperCell
            cell.startProgressFrom(value: 0) { [self] in
                tutorialVM.nextTutorial()
            }
            
//            if index.prevIndex < index.currentIndex {
//                cell.startProgressFrom(value: 0) { [self] in
//                    if !tutorialVM.isLastIndex {
//                        tutorialVM.nextTutorial()
//                    }
//                }
//            } else {
//                let prevCell = self.cellForItem(at: .init(row: index.prevIndex, section: 0)) as! TutorialStepperCell
//                prevCell.resetProgress()
//                cell.resetProgress()
//                cell.startProgressFrom(value: 0) {
//                    self.tutorialVM.nextTutorial()
//                }
//            }
        }.store(in: &cancellables)
    }
}

// MARK: - CollectionView Delegate

extension TutorialStepperContainerView: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tutorialVM.tutorials.count
	}

	func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: TutorialStepperCell.cellReuseID,
			for: indexPath
		) as! TutorialStepperCell
		cell.tutStepperCellVM = TutorialStepViewModel()
        cell.configCell()
		return cell
	}
}

// MARK: - CollectionView DataSource

extension TutorialStepperContainerView: UICollectionViewDelegate {}

extension TutorialStepperContainerView: UICollectionViewDelegateFlowLayout {
	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		sizeForItemAt indexPath: IndexPath
	) -> CGSize {
        CGSize(width: Int(collectionView.frame.width) / tutorialVM.tutorials.count, height: 3)
	}

	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		minimumLineSpacingForSectionAt section: Int
	) -> CGFloat {
		8
	}
}
