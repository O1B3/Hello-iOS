
import Foundation
import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class MyRecordsViewController: BaseViewController<MyRecordsReactor> {
  
  
  private let clearAllButton = UIButton(configuration: .plain()).then {
    $0.configuration?.title = "전체 삭제"
    $0.configuration?.baseForegroundColor = .systemRed
  }
    
  lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: makeLayout()
  )
  
  private lazy var dataSource = makeDataSource(collectionView)
  
  let deleteRelay = PublishRelay<String>()
  
  init(reactor: MyRecordsReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }
  
  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupUI() {
    
    navigationItem.title = "모의 면접 기록"
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: clearAllButton)
    
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
  }
  
  private func makeDataSource(_ collectionView: UICollectionView) ->
  UICollectionViewDiffableDataSource<Int, RecordGroupCellVM> {
    // 셀 정의
    let recordCell = UICollectionView.CellRegistration<RecordGroupCell, RecordGroupCellVM> { cell, _, item in
      cell.configure(id: item.id, dateText: item.dateText, subtitle: item.subtitle)
    }
    
    //데이터 소스 정의
    let dataSource = UICollectionViewDiffableDataSource<Int, RecordGroupCellVM>(
      collectionView: collectionView
    ) { collectionView, indexPath, item in
      collectionView.dequeueConfiguredReusableCell(using: recordCell, for: indexPath, item: item)
    }
    return dataSource
  }
  
  func makeLayout() -> UICollectionViewLayout {
    var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
    configuration.showsSeparators = false
    
    configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in

      guard let id = self?.dataSource.itemIdentifier(for: indexPath)?.id else {
        return UISwipeActionsConfiguration(actions: [])
      }
      
      let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _,_,completion in
        self?.deleteRelay.accept(id)
        completion(true)
      }
      
      deleteAction.image = UIImage(systemName: "trash")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal) // SF Symbol 아이콘 추가, 색 설정
      deleteAction.backgroundColor = .systemBackground // 배경색 변경

      let config = UISwipeActionsConfiguration(actions: [deleteAction])
      config.performsFirstActionWithFullSwipe = false // 스와이프만으로 삭제 방지
      return config
    }
    
    return UICollectionViewCompositionalLayout { _, environment in
      NSCollectionLayoutSection.list(
        using: configuration,
        layoutEnvironment: environment
      ).then { section in
        section.contentInsets = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
        section.interGroupSpacing = 20
      }
    }
  }
  
  override func bind(reactor: MyRecordsReactor) {
    
    rx.viewWillAppear.map { _ in .sortByDate }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    let selectedGroup = collectionView.rx.itemSelected
      .withUnretained(dataSource)
      .compactMap { dataSource, indexPath in
        dataSource.itemIdentifier(for: indexPath)?.id
      }
      .share()
    
    selectedGroup
      .map { .selectGroup($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    selectedGroup
      .bind { [weak self] _ in
        let group = reactor.currentState.selectedGroup?.records
        let reactor = RecordDetailReactor(items: group ?? [])
        let detailVC = RecordDetailViewController(reactor: reactor)
        detailVC.modalPresentationStyle = .pageSheet
        detailVC.modalTransitionStyle = .coverVertical
        
        if let sheet = detailVC.sheetPresentationController {
          sheet.detents = [.large()]
          sheet.prefersGrabberVisible = true
          sheet.preferredCornerRadius = 20
        }
        self?.present(UINavigationController(rootViewController: detailVC), animated: true)
      }
      .disposed(by: disposeBag)
    
    deleteRelay.map { .deleteGroup($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    clearAllButton.rx.tap
      .withUnretained(self)
      .flatMap { `self`, _ in
        UIAlertController.rx.alert(
          on: self,
          title: "모든 기록 삭제",
          message: "모든 모의 면접 기록을 삭제하시겠습니까?",
          actions: [
            .cancel("취소"),
            .destructive("삭제", payload: .deleteAllGroups),
          ])
      }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    reactor.state
      .map(\.cells) // [RecordGroupCellVM]
      .distinctUntilChanged()
      .bind { [weak self] cells in
        guard let self else { return }
        var snapshot = NSDiffableDataSourceSnapshot<Int, RecordGroupCellVM>()
        snapshot.appendSections([0])
        snapshot.appendItems(cells, toSection: 0)
        self.dataSource.apply(snapshot, animatingDifferences: true)
      }
      .disposed(by: disposeBag)
    
    // 전체 기록이 0건이면 전체 삭제버튼 hidden 처리
    reactor.state
      .map { $0.cells.isEmpty }
      .distinctUntilChanged()
      .bind(to: clearAllButton.rx.isHidden)
      .disposed(by: disposeBag)
  }
  
}
