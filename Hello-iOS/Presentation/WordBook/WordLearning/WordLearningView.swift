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
  let addContentView = AddContentView().then {
    $0.isHidden = true
  }

  let reulstView = WordResultView().then {
    $0.isHidden = true
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = .background
    setupUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI() {
    addSubview(cardStack)
    addSubview(addContentView)
    addSubview(reulstView)

    cardStack.snp.makeConstraints {
      $0.top.equalTo(self.safeAreaLayoutGuide).offset(45)
      $0.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(38)
      $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(98)
    }

    addContentView.snp.makeConstraints {
      $0.top.equalTo(self.safeAreaLayoutGuide).offset(40)
      $0.centerX.equalToSuperview()
      $0.width.equalToSuperview().multipliedBy(0.8)
      $0.height.equalTo(addContentView.snp.width).multipliedBy(1.5)
    }

    reulstView.snp.makeConstraints {
      $0.top.equalTo(self.safeAreaLayoutGuide)
      $0.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(30)
      $0.bottom.equalTo(self.safeAreaLayoutGuide)
    }
  }

  func card(concept: String, explain: String, total: Int, index: Int) -> ConceptCard {
    let card = ConceptCard()

    card.configure(concept: concept, explain: explain, total: total, current: index)

    return card
  }
}
