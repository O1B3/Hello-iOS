//
//  ConceptCard.swift
//  Hello-iOS
//
//  Created by seongjun cho on 8/8/25.
//

import UIKit
import Shuffle
import SnapKit
import Then

class ConceptCard: SwipeCard {

  let cardView = UIView().then {
    $0.backgroundColor = .card
    $0.layer.cornerRadius = 20
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowRadius = 3
    $0.layer.shadowOpacity = 0.35
  }

  let scrollView = UIScrollView().then {
    $0.isHidden = true
  }

  let conceptLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 48, weight: .bold)
    $0.textColor = .label
    $0.textAlignment = .center
    $0.numberOfLines = 0
  }

  let explainLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 20)
    $0.textColor = .label
    $0.textAlignment = .center
    $0.numberOfLines = 0
    $0.isHidden = true
  }

  let indexLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 20, weight: .bold)
    $0.textColor = .secondaryLabel
    $0.textAlignment = .center
  }

  let leftOverlay = UIView()

  let rightOverlay = UIView()

  let leftLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 32, weight: .bold)
    $0.textColor = .wrong
    $0.textAlignment = .center
    $0.text = "다음에"
  }

  let leftLabelContainer = UIView().then {
    $0.layer.borderColor = UIColor.wrong.cgColor
    $0.layer.borderWidth = 5
    $0.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 12)
  }

  let rightLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 32, weight: .bold)
    $0.textColor = .correct
    $0.textAlignment = .center
    $0.text = "외웠어요!"
  }

  let rightLabelContainer = UIView().then {
    $0.layer.borderColor = UIColor.correct.cgColor
    $0.layer.borderWidth = 5
    $0.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 12)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupCardView()
    self.swipeDirections = [.left, .right]
    self.setOverlays([.left: leftOverlay, .right: rightOverlay])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.shadowPath = UIBezierPath(
      roundedRect: self.cardView.bounds,
      cornerRadius: self.cardView.layer.cornerRadius
    ).cgPath
  }

  private func setupCardView() {

    content = cardView
    cardView.addSubview(conceptLabel)
    cardView.addSubview(explainLabel)
    cardView.addSubview(indexLabel)
    cardView.addSubview(scrollView)
    leftOverlay.addSubview(leftLabelContainer)
    leftLabelContainer.addSubview(leftLabel)
    rightOverlay.addSubview(rightLabelContainer)
    rightLabelContainer.addSubview(rightLabel)

    indexLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview().offset(15)
      $0.height.equalTo(indexLabel.font.lineHeight)
    }

    scrollView.addSubview(explainLabel)

    scrollView.snp.makeConstraints {
      $0.top.equalTo(indexLabel.snp.bottom).offset(10)
      $0.leading.bottom.trailing.equalToSuperview().inset(10).priority(999)
    }

    explainLabel.snp.makeConstraints {
      $0.leading.trailing.equalTo(scrollView.frameLayoutGuide)
      $0.top.equalTo(scrollView.contentLayoutGuide)
      $0.bottom.equalTo(scrollView.contentLayoutGuide)
    }

    conceptLabel.snp.makeConstraints {
      $0.top.bottom.leading.trailing.equalToSuperview().inset(10).priority(999)
    }

    scrollView.contentLayoutGuide.snp.makeConstraints {
      $0.height.greaterThanOrEqualTo(scrollView.frameLayoutGuide)
    }

    leftLabelContainer.snp.makeConstraints {
      $0.top.equalToSuperview().offset(60)
      $0.leading.equalToSuperview().offset(20)
    }

    leftLabel.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
    }

    rightLabelContainer.snp.makeConstraints {
      $0.top.equalToSuperview().offset(60)
      $0.trailing.equalToSuperview().inset(20)
    }

    rightLabel.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
    }
  }
  
  func configure(concept: String, explain: String, total: Int, current: Int) {
    conceptLabel.text = concept
    explainLabel.text = explain
    indexLabel.text = "\(current)/\(total)"
  }

  func toggleLabels() {
    conceptLabel.isHidden.toggle()
    explainLabel.isHidden.toggle()
    scrollView.isHidden.toggle()
  }
}
