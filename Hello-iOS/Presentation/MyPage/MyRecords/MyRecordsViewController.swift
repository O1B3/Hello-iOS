
import Foundation
import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class MyRecordsViewController: BaseViewController<MyRecordsReactor> {
  // UI
  private enum Section { case main }
  
  lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: makeLayout()
  )
  
  private lazy var dataSource = makeDataSource(collectionView)
  
  init(reactor: MyRecordsReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }
  
  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupUI() {
    title = "모의 면접 기록"
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "초기화",
      style: .plain,
      target: nil,
      action: nil
    )
    
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
  }
  
  private func makeDataSource(_ collectionView: UICollectionView) ->
  UICollectionViewDiffableDataSource<Section, RecordGroupCellVM> {
    // 셀 정의
    let recordCell = UICollectionView.CellRegistration<RecordGroupCell, RecordGroupCellVM> { cell, _, item in
      cell.configure(id: item.id, dateText: item.dateText, subtitle: item.subtitle)
    }
    
    //데이터 소스 정의
    let dataSource = UICollectionViewDiffableDataSource<Section, RecordGroupCellVM>(
      collectionView: collectionView
    ) { collectionView, indexPath, item in
      collectionView.dequeueConfiguredReusableCell(using: recordCell, for: indexPath, item: item)
    }
    return dataSource
  }
  
  func makeLayout() -> UICollectionViewLayout {
    var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
    configuration.showsSeparators = false
    // TODO: 삭제기능 추가
    
    return UICollectionViewCompositionalLayout { _, environment in
      NSCollectionLayoutSection.list(
        using: configuration,
        layoutEnvironment: environment
      ).then { section in
        section.contentInsets = .init(top: 10, leading: 20, bottom: 10, trailing: 20)
        section.interGroupSpacing = 20
      }
    }
  }
  
  override func bind(reactor: MyRecordsReactor) {
    
    rx.viewDidAppear.map { _ in .sortByDate }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    collectionView.rx.itemSelected
      .withUnretained(dataSource)
      .compactMap { dataSource, indexPath in
        dataSource.itemIdentifier(for: indexPath)?.id
      }
      .map { .selectGroup($0) }   // 선택한 그룹 id 전달
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    reactor.state
      .map(\.cells) // [RecordGroupCellVM]
      .distinctUntilChanged()
      .bind { [weak self] cells in
        guard let self else { return }
        var snapshot = NSDiffableDataSourceSnapshot<Section, RecordGroupCellVM>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cells, toSection: .main)
        self.dataSource.apply(snapshot, animatingDifferences: true)
      }
      .disposed(by: disposeBag)

  }
  
}
