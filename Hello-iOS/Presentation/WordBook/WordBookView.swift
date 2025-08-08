//
//  WordBookView.swift
//  Hello-iOS
//
//  Created by seongjun cho on 8/7/25.
//

import UIKit

import SnapKit
import Then

final class WordBookView: UIView {

  lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: makeCollectionViewLayout()).then {
    $0.showsVerticalScrollIndicator = false
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI() {
    addSubview(collectionView)

    collectionView.snp.makeConstraints {
      $0.top.leading.trailing.bottom.equalTo(self.safeAreaLayoutGuide)
    }
  }

  private func makeCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in

      let item = NSCollectionLayoutItem(
        layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                          heightDimension: .fractionalHeight(1.0)))

      let group = NSCollectionLayoutGroup.vertical(
        layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                          heightDimension: .absolute(106)),
        subitems: [item])

      let section = NSCollectionLayoutSection(group: group)
      section.interGroupSpacing = 8
      section.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)

      return section
    }
  }
}
