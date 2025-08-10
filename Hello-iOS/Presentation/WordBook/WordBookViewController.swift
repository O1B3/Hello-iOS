//
//  WordBookViewController.swift
//  Hello-iOS
//
//  Created by seongjun cho on 8/7/25.
//

import UIKit

import RxCocoa
import RxSwift

class WordBookViewController: BaseViewController<WordBookReactor> {

  private let wordBookView = WordBookView()

  init(reactor: WordBookReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    self.view = wordBookView
  }

  override func viewDidLoad() {
    self.navigationItem.title = "단어장"

    let mockConcepts = MockConcept(
      id: 1,
      categoryId: 1,
      concept: "MVVM",
      explain: "대충 MVVM에 대한 설명",
      latestUpdate: Date(),
      isMemory: true
    )

    let mockConcepts2 = MockConcept(
      id: 2,
      categoryId: 1,
      concept: "MVVM",
      explain: "대충 MVVM에 대한 설명",
      latestUpdate: Date(),
      isMemory: false
    )

    let mockData1 = MockWordBook(
      category: "디자인 패턴",
      id: 1,
      concepts: [mockConcepts, mockConcepts2]
    )
    let mockData2 = MockWordBook(category: "디자인 패턴", id: 2, concepts: [mockConcepts])
    let mockData3 = MockWordBook(category: "디자인 패턴", id: 3, concepts: [mockConcepts])
    let mockData4 = MockWordBook(category: "디자인 패턴", id: 4, concepts: [mockConcepts])
    let mockData5 = MockWordBook(category: "디자인 패턴", id: 5, concepts: [mockConcepts])
    let mockData6 = MockWordBook(category: "디자인 패턴", id: 6, concepts: [mockConcepts])

    wordBookView.dataApply(data: [mockData1,
                     mockData2,
                     mockData3,
                     mockData4,
                     mockData5,
                     mockData6
                    ])
  }

  override func bind(reactor: WordBookReactor) {
    wordBookView.collectionView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        let container = DIContainer.shared
        let vc: WordLearningViewController = container.resolve()

        self?.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
  }
}
