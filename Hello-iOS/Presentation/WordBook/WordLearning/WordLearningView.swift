//
//  WordLearningView.swift
//  Hello-iOS
//
//  Created by seongjun cho on 8/8/25.
//

import UIKit

import SnapKit
import Then
import Shuffle

class WordLearningView: UIView {

  let cardStack = SwipeCardStack()

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI() {
    addSubview(cardStack)

    cardStack.snp.makeConstraints {
      $0.top.equalTo(self.safeAreaLayoutGuide).offset(45)
      $0.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(38)
      $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(98)
    }
  }

  func card(concept: String, explain: String, total: Int, index: Int) -> ConceptCard {
    let card = ConceptCard()

    card.configure(concept: concept, explain: explain, total: total, current: index)

    return card
  }
}
