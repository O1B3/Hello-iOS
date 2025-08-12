//
//  AddContentView.swift
//  Hello-iOS
//
//  Created by seongjun cho on 8/11/25.
//

import UIKit

import SnapKit
import Then

final class AddContentView: UIView {

  let closeButton = UIButton().then {
    $0.setImage(UIImage(systemName: "xmark"), for: .normal)
    $0.tintColor = .label
  }
  let contentUI = LabelNTextview(title: "개념")
  let explainUI = LabelNTextview(title: "설명")
  let questionUI = LabelNTextview(title: "질문")
  let answerUI = LabelNTextview(title: "답변")
  let stackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
  }

  let addButton: UIButton = .init(type: .system).then {
    $0.setTitle("추가하기", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = .main
    $0.layer.cornerRadius = 10
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
    self.layer.cornerRadius = 10
    self.layer.shadowColor = UIColor.black.cgColor
    self.layer.shadowOffset = CGSize(width: 0, height: 4)
    self.layer.shadowRadius = 3
    self.layer.shadowOpacity = 0.35
    closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI() {
    backgroundColor = .card

    addSubview(closeButton)
    addSubview(addButton)
    addSubview(stackView)

    stackView.addArrangedSubview(contentUI)
    stackView.addArrangedSubview(explainUI)
    stackView.addArrangedSubview(questionUI)
    stackView.addArrangedSubview(answerUI)

    closeButton.snp.makeConstraints {
      $0.top.equalToSuperview().offset(17)
      $0.trailing.equalToSuperview().inset(17)
    }

    stackView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(56)
      $0.centerX.equalToSuperview()
      $0.width.equalToSuperview().multipliedBy(0.8)
    }

    addButton.snp.makeConstraints {
      $0.top.greaterThanOrEqualTo(stackView.snp.bottom)
      $0.centerX.equalToSuperview()
      $0.width.equalToSuperview().multipliedBy(0.6)
      $0.height.equalTo(52)
      $0.bottom.equalToSuperview().inset(16)
    }
  }

  @objc func closeTapped() {
    self.isHidden = true
    contentUI.removeText()
    explainUI.removeText()
    questionUI.removeText()
    answerUI.removeText()
  }
}
