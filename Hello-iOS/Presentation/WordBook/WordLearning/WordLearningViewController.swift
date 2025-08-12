//
//  WordLearningViewController.swift
//  Hello-iOS
//
//  Created by seongjun cho on 8/8/25.
//

import UIKit

import Shuffle
import RxSwift
import RxCocoa
import SnapKit

class WordLearningViewController: BaseViewController<WordLearningReactor> {

  private let wordLearningView = WordLearningView()

  init(reactor: WordLearningReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = wordLearningView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    wordLearningView.cardStack.dataSource = self
    wordLearningView.cardStack.delegate = self
    self.title = "개념 공부"
    setupNavigationBar()
  }

  private func setupNavigationBar() {
    let plusButton = UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self,
      action: #selector(didTapAddButton)
    )
    self.navigationItem.rightBarButtonItem = plusButton
  }

  override func bind(reactor: WordLearningReactor) {
    wordLearningView.addContentView.addButton.rx
      .tap
      .subscribe(onNext: { [weak self] in
      self?.didTapAddContentButton()
    }).disposed(by: disposeBag)

    wordLearningView.reulstView.backButton.rx
      .tap
      .subscribe(onNext: { [weak self] in
        self?.navigationController?.popViewController(animated: true)
    }).disposed(by: disposeBag)

    wordLearningView.reulstView.retryButton.rx
      .tap
      .subscribe(onNext: { [weak self] in
        self?.wordLearningView.reulstView.isHidden = true
        for _ in 0..<reactor.currentState.concepts.count {
          self?.wordLearningView.cardStack.undoLastSwipe(animated: false)
        }
    }).disposed(by: disposeBag)

    reactor.state.map { $0.concepts }.subscribe(onNext: { [weak self] concepts in
      self?.wordLearningView
        .reulstView
        .configure(correct: concepts.filter { $0.isMemory }.count,
                   wrong: concepts.filter { $0.isMemory == false }.count
        )
    }).disposed(by: disposeBag)
  }
}

extension WordLearningViewController: SwipeCardStackDataSource, SwipeCardStackDelegate {
  func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
    let concepts = reactor?.currentState.concepts ?? []
    return wordLearningView.card(concept: concepts[index].concept,
                                 explain: concepts[index].explain,
                                 total: concepts.count,
                                 index: index + 1)
  }

  func numberOfCards(in cardStack: SwipeCardStack) -> Int {
    return  reactor?.currentState.concepts.count ?? 0
  }

  func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
    if direction == .right {
      reactor?.action.onNext(.memorize(index, true))
    } else {
      reactor?.action.onNext(.memorize(index, false))
    }
  }

  func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
    if let card = cardStack.card(forIndexAt: index) as? ConceptCard {
      card.toggleLabels()
    }
  }

  func didSwipeAllCards(_ cardStack: SwipeCardStack) {
    // TODO: 결과화면 isHidden false
    wordLearningView.reulstView.isHidden = false
  }
}

extension WordLearningViewController {
  @objc func didTapAddButton() {
    wordLearningView.addContentView.isHidden = false
  }

  func didTapAddContentButton() {
    let contentView = wordLearningView.addContentView
    let concept = contentView.contentUI.getText()
    let explain = contentView.explainUI.getText()
    let question = contentView.questionUI.getText()
    let answer = contentView.answerUI.getText()

    contentView.contentUI.removeText()
    contentView.explainUI.removeText()
    contentView.questionUI.removeText()
    contentView.answerUI.removeText()
    wordLearningView.addContentView.isHidden = true
    reactor?.action.onNext(
      .addContent(concept,
                  explain,
                  question,
                  answer)
    )

    contentView.closeTapped()
  }
}
