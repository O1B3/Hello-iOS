//
//  ResultCardView.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/11/25.
//
import UIKit
import SnapKit
import Then

class ResultCardView: UIView {

  private let scrollView = UIScrollView().then {
    $0.showsVerticalScrollIndicator = false
  }

  private let contentView = UIView()

  // 질문
  private let questionLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = .systemFont(ofSize: 20, weight: .bold)
    $0.textColor = .label
  }

  let divider1 = UIView().then {
    $0.backgroundColor = .separator
  }

  // 모범답안
  private let modelAnswerTitle = UILabel().then {
    $0.text = "모범답안"
    $0.font = .systemFont(ofSize: 15, weight: .semibold)
    $0.textColor = .secondaryLabel
  }
  private let modelAnswerLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = .systemFont(ofSize: 18, weight: .regular)
    $0.textColor = .label
  }

  let divider2 = UIView().then {
    $0.backgroundColor = .separator
  }

  // 내 답변
  private let myAnswerTitle = UILabel().then {
    $0.text = "내 답변"
    $0.font = .systemFont(ofSize: 15, weight: .semibold)
    $0.textColor = .secondaryLabel
  }

  private let myAnswerLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = .systemFont(ofSize: 18, weight: .regular)
    $0.textColor = .label
  }

  private let vStack = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 12
    $0.alignment = .fill
    $0.distribution = .fill
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
    setupConstraints()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupUI()
    setupConstraints()
  }

  private func setupUI() {
    backgroundColor = .card

    addSubview(scrollView)

    scrollView.addSubview(contentView)
    contentView.addSubview(vStack)

    // 상단 질문 + 구분선처럼 간격 주는 구성
    vStack.addArrangedSubview(questionLabel)
    vStack.addArrangedSubview(divider1)

    vStack.addArrangedSubview(modelAnswerTitle)
    vStack.addArrangedSubview(modelAnswerLabel)
    vStack.addArrangedSubview(divider2)

    vStack.addArrangedSubview(myAnswerTitle)
    vStack.addArrangedSubview(myAnswerLabel)
  }

  private func setupConstraints() {
    scrollView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }

    contentView.snp.makeConstraints {
      $0.directionalEdges.equalTo(scrollView.contentLayoutGuide)
      $0.width.equalTo(scrollView.frameLayoutGuide)
    }

    vStack.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(16)
    }

    divider1.snp.makeConstraints{
      $0.height.equalTo(1)
    }

    divider2.snp.makeConstraints{
      $0.height.equalTo(1)
    }
  }

  // 외부에서 데이터 주입
  func configure(question: String, modelAnswer: String, myAnswer: String) {
    questionLabel.text = question
    modelAnswerLabel.text = modelAnswer
    myAnswerLabel.text = myAnswer
  }
}
