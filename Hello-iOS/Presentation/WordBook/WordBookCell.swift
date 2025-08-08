//
//  WordBookCell.swift
//  Hello-iOS
//
//  Created by seongjun cho on 8/7/25.
//

import UIKit

import SnapKit
import Then

class WordBookCell: UICollectionViewCell {
  let identifier: String = "WordBookCell"

  private let titleLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 28, weight: .bold)
  }

  private let progressLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 16, weight: .bold)
  }

  private let progressView = UIProgressView(progressViewStyle: .bar).then {
    $0.progressTintColor = .main
    $0.layer.cornerRadius = 2
    $0.layer.masksToBounds = true
    $0.backgroundColor = .secondarySystemFill
  }

  private let verticalStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 12
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(verticalStackView)
    verticalStackView.addArrangedSubview(titleLabel)
    verticalStackView.addArrangedSubview(progressLabel)
    verticalStackView.addArrangedSubview(progressView)

    progressView.snp.makeConstraints {
      $0.height.equalTo(5)
    }

    progressLabel.snp.makeConstraints {
      $0.height.equalTo(progressLabel.font.lineHeight)
    }

    titleLabel.snp.makeConstraints {
      $0.height.equalTo(titleLabel.font.lineHeight)
    }

    verticalStackView.snp.makeConstraints {
      $0.top.leading.trailing.bottom.equalToSuperview().inset(16)
    }

    self.backgroundColor = .card
    self.layer.cornerRadius = 20
    self.layer.shadowColor = UIColor.black.cgColor
    self.layer.shadowOffset = CGSize(width: 0, height: 4)
    self.layer.shadowRadius = 3
    self.layer.shadowOpacity = 0.35
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(title: String, memorized: Int, total: Int) {
    titleLabel.text = title
    progressLabel.text = "\(memorized)/\(total) [\(Int(Float(memorized) / Float(total) * 100))%]"
    progressView.progress = Float(memorized) / Float(total)
  }
}
