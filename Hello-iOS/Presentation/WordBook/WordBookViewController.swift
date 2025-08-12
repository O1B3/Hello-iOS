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
  }

  override func bind(reactor: WordBookReactor) {
    wordBookView.collectionView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        let container = DIContainer.shared
        let vc: WordLearningViewController = container.resolve()

        self?.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)

    self.rx
      .viewDidLoad
      .subscribe(onNext: { _ in reactor.action.onNext(.fetchWordBook) })
      .disposed(by: disposeBag)
    
    reactor
        .state
        .bind { [weak dataSource = wordBookView.dataSource] item in
          var snapshot = NSDiffableDataSourceSnapshot<Int, DomainCategories>()
            snapshot.appendSections([0])
          snapshot.appendItems(item.wordBooks, toSection: 0)
          dataSource?.apply(snapshot, animatingDifferences: true)
        }
        .disposed(by: disposeBag)
  }
}
