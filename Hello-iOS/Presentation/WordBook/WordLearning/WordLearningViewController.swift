//
//  WordLearningViewController.swift
//  Hello-iOS
//
//  Created by seongjun cho on 8/8/25.
//

import UIKit
import Shuffle

class WordLearningViewController: BaseViewController<WordLearningReactor> {

  let wordLearningView = WordLearningView()
  let conceptTexts = ["aaaaaaaaaaaaaa", "b", "c", "d", "e", "f", "g", "h", "i", "j"]
  let explainTexts = ["1ddddsdsdsdsdsdsdsdsdsdsdsdsdddddsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsddddsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsddddsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsddddsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsddddsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsddddsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsddddsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsddddsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsddddsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsddddsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsddddsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsddddsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsddddsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsddddsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsddddsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsddddsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdssdsdsdsdsdsdsds", "2", "3", "4", "5", "6", "7", "8", "9", "10"]

  override func loadView() {
    view = wordLearningView
  }

  override func viewDidLoad() {
    wordLearningView.cardStack.dataSource = self
    wordLearningView.cardStack.delegate = self
    self.title = "개념 공부"
    setupNavigationBar()
  }

  private func setupNavigationBar() {
    let plusButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
    self.navigationItem.rightBarButtonItem = plusButton
  }
}

extension WordLearningViewController: SwipeCardStackDataSource, SwipeCardStackDelegate {
  func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
    return wordLearningView.card(concept: conceptTexts[index],
                                 explain: explainTexts[index],
                                 total: conceptTexts.count,
                                 index: index + 1)
  }

  func numberOfCards(in cardStack: SwipeCardStack) -> Int {
    return conceptTexts.count
  }

  func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
    if let card = cardStack.card(forIndexAt: index) as? ConceptCard {
      card.toggleLabels()
    }
  }
}

@available(iOS 18.0, *)
#Preview {
  WordLearningViewController()
}
