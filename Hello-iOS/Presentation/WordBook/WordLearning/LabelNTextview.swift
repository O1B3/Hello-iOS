//
//  LabelNTextview.swift
//  Hello-iOS
//
//  Created by seongjun cho on 8/12/25.
//

import UIKit

import SnapKit
import Then

final class LabelNTextview: UIView {

  private let titleLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 17, weight: .bold)
  }

  private let textview = UITextView().then {
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 0.5
    $0.layer.borderColor = UIColor.label.cgColor
    $0.font = .systemFont(ofSize: 17)
    $0.textColor = .black
    $0.backgroundColor = .white
  }
  
  
  init(title: String) {
    super.init(frame: .zero)
    titleLabel.text = title
    setupUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI() {
    addSubview(titleLabel)
    addSubview(textview)

    titleLabel.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(titleLabel.font.lineHeight)
    }

    textview.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(titleLabel.font.lineHeight * 2 + 5)
      $0.bottom.equalToSuperview()
    }
  }

  func removeText() {
    textview.text = ""
  }

  func getText() -> String {
    return textview.text
  }
}
