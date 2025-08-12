//
//  WordResultView.swift
//  Hello-iOS
//
//  Created by seongjun cho on 8/12/25.
//

import UIKit

import SnapKit
import Then

final class WordResultView: UIView {

  let resultLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 40, weight: .bold)
    $0.text = "학습 결과"
  }

  let ringView =  RingView().then {
    $0.centerLabel.textColor = .label

    $0.progressColor = .main
  }

  private let resultView = UIView().then {
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 2
    $0.layer.borderColor = UIColor.main.cgColor
    $0.backgroundColor = .background

    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowRadius = 3
    $0.layer.shadowOpacity = 0.35
  }

  private let correctBorderView = UIView().then {
    $0.layer.borderColor = UIColor.correct.cgColor
    $0.layer.borderWidth = 5
  }

  private let correctLabel = UILabel().then {
    $0.text = "외웠어요!"
    $0.font = .systemFont(ofSize: 20, weight: .bold)
    $0.textColor = .correct
    $0.textAlignment = .center
  }

  private let wrongBorderView = UIView().then {
    $0.layer.borderColor = UIColor.wrong.cgColor
    $0.layer.borderWidth = 5
  }

  private let wrongLabel = UILabel().then {
    $0.text = "다음에"
    $0.font = .systemFont(ofSize: 20, weight: .bold)
    $0.textColor = .wrong
    $0.textAlignment = .center
  }

  let correctResultLabel = UILabel().then {
    $0.textAlignment = .center
    $0.font = .systemFont(ofSize: 28, weight: .bold)
    $0.textColor = .correct
    $0.text = "N개"
  }

  let wrongResultLabel = UILabel().then {
    $0.textAlignment = .center
    $0.font = .systemFont(ofSize: 28, weight: .bold)
    $0.textColor = .wrong
    $0.text = "N개"
  }

  let retryButton = UIButton().then {
    $0.layer.cornerRadius = 20
    $0.setTitle("다시하기", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = .main
    $0.layer.masksToBounds = true
    $0.titleLabel?.font = .systemFont(ofSize: 28, weight: .bold)
  }

  let backButton = UIButton().then {
    $0.layer.cornerRadius = 20
    $0.setTitle("돌아가기", for: .normal)
    $0.setTitleColor(.main, for: .normal)
    $0.layer.borderWidth = 1
    $0.layer.masksToBounds = true
    $0.titleLabel?.font = .systemFont(ofSize: 28, weight: .bold)
  }

  let scrollView = UIScrollView().then {
    $0.showsVerticalScrollIndicator = false
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
    addSubview(scrollView)
    scrollView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    let contentView = UIView()
    scrollView.addSubview(contentView)
    contentView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.width.equalToSuperview()
    }

    contentView.addSubview(resultLabel)
    contentView.addSubview(ringView)
    contentView.addSubview(resultView)
    resultView.addSubview(correctBorderView)
    correctBorderView.addSubview(correctLabel)
    resultView.addSubview(wrongBorderView)
    wrongBorderView.addSubview(wrongLabel)
    resultView.addSubview(correctResultLabel)
    resultView.addSubview(wrongResultLabel)
    contentView.addSubview(retryButton)
    contentView.addSubview(backButton)

    resultLabel.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview().offset(20)
      $0.height.equalTo(resultLabel.font.lineHeight)
    }

    ringView.snp.makeConstraints {
      $0.top.equalTo(resultLabel.snp.bottom).offset(34)
      $0.width.height.equalTo(170)
      $0.centerX.equalToSuperview()
    }

    resultView.snp.makeConstraints {
      $0.top.equalTo(ringView.snp.bottom).offset(30)
      $0.leading.trailing.equalToSuperview().inset(2)
      $0.height.equalTo(165)
    }

    correctBorderView.snp.makeConstraints {
      $0.centerY.equalToSuperview().offset(-40)
      $0.height.equalTo(42)
      $0.width.equalTo(114)
      $0.trailing.equalTo(resultView.snp.centerX)
    }

    correctLabel.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    wrongBorderView.snp.makeConstraints {
      $0.centerY.equalToSuperview().offset(40)
      $0.height.equalTo(42)
      $0.width.equalTo(114)
      $0.trailing.equalTo(resultView.snp.centerX)
    }

    wrongLabel.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    correctResultLabel.snp.makeConstraints {
      $0.top.bottom.equalTo(correctBorderView)
      $0.leading.equalTo(correctBorderView.snp.trailing).offset(24)
    }

    wrongResultLabel.snp.makeConstraints {
      $0.top.bottom.equalTo(wrongBorderView)
      $0.leading.equalTo(wrongBorderView.snp.trailing).offset(24)
    }

    retryButton.snp.makeConstraints {
      $0.top.equalTo(resultView.snp.bottom).offset(30)
      $0.height.equalTo(60)
      $0.leading.trailing.equalToSuperview()
    }

    backButton.snp.makeConstraints {
      $0.top.equalTo(retryButton.snp.bottom).offset(20)
      $0.height.equalTo(60)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview().inset(20)
    }
  }

  func configure(correct: Int, wrong: Int) {
    wrongResultLabel.text = "\(wrong) 개"
    correctResultLabel.text = "\(correct) 개"
    ringView.centerLabel.text = String(format: "%.1f", Float(correct) / Float(correct + wrong) * 100)
    ringView.setProgress(CGFloat(Float(correct) / Float(correct + wrong)), animated: true)
  }
}
