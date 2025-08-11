//
//  SelectionInterviewViewController.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/7/25.
//
import UIKit
import ReactorKit
import RxCocoa
import Then
import SnapKit

class SelectionInterviewViewController: BaseViewController<SelectionInterviewReactor> {

  private let wordBookView = WordBookView().then {
    $0.collectionView.allowsMultipleSelection = true
  }

  private let doneButton = UIBarButtonItem(title: "선택 완료", style: .done, target: nil, action: nil)

  override func loadView() {
    self.view = wordBookView
  }

  init(reactor: SelectionInterviewReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    navigationItem.title = "단어장 선택"
    navigationItem.rightBarButtonItem = doneButton
//    doneButton.isEnabled = false // 초기는 비활성화

//    let mockConcepts = MockConcept(
//      id: 1,
//      categoryId: 1,
//      concept: "MVVM",
//      explain: "대충 MVVM에 대한 설명",
//      latestUpdate: Date(),
//      isMemory: true
//    )
//
//    let mockConcepts2 = MockConcept(
//      id: 2,
//      categoryId: 1,
//      concept: "MVVM",
//      explain: "대충 MVVM에 대한 설명",
//      latestUpdate: Date(),
//      isMemory: false
//    )
//
//    let mockData1 = MockWordBook(
//      category: "디자인 패턴",
//      id: 1,
//      concepts: [mockConcepts, mockConcepts2]
//    )
//    let mockData2 = MockWordBook(category: "디자인 패턴", id: 2, concepts: [mockConcepts])
//    let mockData3 = MockWordBook(category: "디자인 패턴", id: 3, concepts: [mockConcepts])
//    let mockData4 = MockWordBook(category: "디자인 패턴", id: 4, concepts: [mockConcepts])
//    let mockData5 = MockWordBook(category: "디자인 패턴", id: 5, concepts: [mockConcepts])
//    let mockData6 = MockWordBook(category: "디자인 패턴", id: 6, concepts: [mockConcepts])
//
//    wordBookView.dataApply(data: [mockData1,
//                                  mockData2,
//                                  mockData3,
//                                  mockData4,
//                                  mockData5,
//                                  mockData6
//                                 ])
  }

  override func bind(reactor _: SelectionInterviewReactor) {
    wordBookView.collectionView.rx.itemSelected
      .subscribe(onNext: { indexPath in
        guard let cell = self.wordBookView.collectionView.cellForItem(at: indexPath) else { return }
        cell.layer.borderWidth = 4
        cell.layer.borderColor = UIColor.main.cgColor
        print("선택 셀 : \(indexPath)")
      })
      .disposed(by: disposeBag)

    wordBookView.collectionView.rx.itemDeselected
      .subscribe(onNext: { indexPath in
        guard let cell = self.wordBookView.collectionView.cellForItem(at: indexPath) else { return }
        cell.layer.borderWidth = 0
        cell.layer.borderColor = nil
        print("선택해제 셀 : \(indexPath)")
      })
      .disposed(by: disposeBag)

    doneButton.rx.tap
      .withUnretained(self)
      .bind { owner, _ in
        let container = DIContainer.shared
        container.register(InterviewRoomViewController(reactor: InterviewRoomReactor()))
        let InterviewRoomVC: InterviewRoomViewController = container.resolve()
        owner.navigationController?.pushViewController(InterviewRoomVC, animated: true)
      }
      .disposed(by: disposeBag)
  }
}
