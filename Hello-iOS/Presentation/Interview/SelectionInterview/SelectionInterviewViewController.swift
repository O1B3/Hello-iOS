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

  private let doneButton = UIBarButtonItem(title: "선택 완료", style: .done, target: nil, action: nil).then {
    $0.isEnabled = true // 초기는 비활성화(현재 임시로 활성화)
  }

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
  }

  override func bind(reactor: SelectionInterviewReactor) {
    wordBookView.collectionView.rx.itemSelected
      .subscribe(onNext: { indexPath in
        guard let model = self.wordBookView.dataSource.itemIdentifier(for: indexPath) else { return }
        reactor.action.onNext(.selectCategory(model.id))

        guard let cell = self.wordBookView.collectionView.cellForItem(at: indexPath) else { return }
        cell.layer.borderWidth = 4
        cell.layer.borderColor = UIColor.main.cgColor
        print("선택 셀 : \(indexPath) model.id: \(model.id)")
      })
      .disposed(by: disposeBag)

    wordBookView.collectionView.rx.itemDeselected
      .subscribe(onNext: { indexPath in
        guard let model = self.wordBookView.dataSource.itemIdentifier(for: indexPath) else { return }
        reactor.action.onNext(.deselectCategory(model.id))
        guard let cell = self.wordBookView.collectionView.cellForItem(at: indexPath) else { return }
        cell.layer.borderWidth = 0
        cell.layer.borderColor = nil
        print("선택해제 셀 : \(indexPath) model.id: \(model.id)")
      })
      .disposed(by: disposeBag)

    self.rx
      .viewDidLoad
      .subscribe(onNext: { _ in reactor.action.onNext(.fetchWordBook) })
      .disposed(by: disposeBag)

    reactor.state
      .bind { [weak dataSource = wordBookView.dataSource] item in
        var snapshot = NSDiffableDataSourceSnapshot<Int, DomainCategories>()
        snapshot.appendSections([0])
        snapshot.appendItems(item.wordBooks, toSection: 0)
        dataSource?.apply(snapshot, animatingDifferences: true)
      }
      .disposed(by: disposeBag)

    doneButton.rx.tap
      .withUnretained(self)
      .bind { owner, _ in
        let container = DIContainer.shared
        let InterviewRoomVC: InterviewRoomViewController = container.resolve()
        owner.navigationController?.pushViewController(InterviewRoomVC, animated: true)
      }
      .disposed(by: disposeBag)
  }
}
