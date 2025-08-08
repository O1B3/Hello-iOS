//
//  WordBookViewController.swift
//  Hello-iOS
//
//  Created by seongjun cho on 8/7/25.
//

import UIKit

class WordBookViewController: BaseViewController<WordBookReactor> {

  private let wordBookView = WordBookView()
  private lazy var dataSource = makeCollectionViewDataSource(wordBookView.collectionView)

  override func loadView() {
    self.view = wordBookView
  }

  override func viewDidLoad() {
    self.navigationItem.title = "단어장"

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
//    dataApply(data: [mockData1,
//                     mockData2,
//                     mockData3,
//                     mockData4,
//                     mockData5,
//                     mockData6
//                    ])
  }

  private func dataApply(data: [MockWordBook]) {
    var snapshot = NSDiffableDataSourceSnapshot<Int, MockWordBook>()

    snapshot.appendSections([0])
    snapshot.appendItems(data, toSection: 0)

    dataSource.apply(snapshot, animatingDifferences: true)
  }

  private func makeCollectionViewDataSource(
    _ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, MockWordBook> {

      // 셀 설정
      let cellRegistration = UICollectionView.CellRegistration<WordBookCell, MockWordBook> { cell, _, item in
        cell.configure(title: item.category,
                       memorized: item.concepts
                                      .map { $0.isMemory }
                                      .filter { $0 }.count,
                       total: item.concepts.count)
      }

      // 아이템별 데이터 소스 등록
      let dataSource = UICollectionViewDiffableDataSource<Int, MockWordBook>(
        collectionView: collectionView) { collectionView, indexPath, item in
          return collectionView
            .dequeueConfiguredReusableCell(
              using: cellRegistration,
              for: indexPath,
              item: item
            )

      }

      return dataSource
    }
}
