//
//  InterviewRoomViewController.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/7/25.
//
import UIKit
import ReactorKit
import RxCocoa
import Then
import SnapKit
import Speech
import AVFoundation

class InterviewRoomViewController: BaseViewController<InterviewRoomReactor> {

  private let questionStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 10
  }

  private let verticalBar = UIView().then {
    $0.backgroundColor = .main
    $0.layer.cornerRadius = 2
    $0.clipsToBounds = true
  }

  private let questionLable = UILabel().then {
    $0.textColor = .label
    $0.numberOfLines = 0
    $0.backgroundColor = .clear
    $0.font = .systemFont(ofSize: 23, weight: .bold)
    $0.text = "Array에 대해서 설명해주세요 Array에 대해서 설명해주세요 Array에 대해서 설명해주세요 Array에 대해서 설명해주세요."
  }

  private let interviewerImageView = UIImageView().then {
    let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
    $0.image = UIImage(systemName: "person", withConfiguration: config)
    $0.contentMode = .scaleAspectFit
    $0.layer.cornerRadius = 50
    $0.tintColor = .main
    $0.backgroundColor = .card
    $0.clipsToBounds = true
  }

  private let myAnswerLabel = UILabel().then {
    $0.textColor = .label
    $0.numberOfLines = 0
    $0.backgroundColor = .clear
    $0.font = .systemFont(ofSize: 23, weight: .medium)
    $0.text = "Array에 대해서 설명해주세요 Array에 대해서 설명해주세요 Array에 대해서 설명해주세요 Array에 대해서 설명해주세요."
  }

  private let micStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.distribution = .fillEqually
    $0.spacing = 10
  }

  private let leftButton = UIButton(type: .system).then {
    let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
    $0.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
    $0.tintColor = .main
  }

  private let microphoneImageView = UIImageView().then {
    let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
    $0.image = UIImage(systemName: "mic", withConfiguration: config)
    $0.contentMode = .scaleAspectFit
    $0.tintColor = .main
  }

  private let rightButton = UIButton(type: .system).then {
    let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
    $0.setImage(UIImage(systemName: "chevron.right", withConfiguration: config), for: .normal)
    $0.tintColor = .main
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setConstraints()
  }

  init(reactor: InterviewRoomReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // UI 추가
  override func setupUI() {
    [questionStackView, interviewerImageView, myAnswerLabel, micStackView].forEach { view.addSubview($0) }
    questionStackView.addArrangedSubview(verticalBar)
    questionStackView.addArrangedSubview(questionLable)
    micStackView.addArrangedSubview(leftButton)
    micStackView.addArrangedSubview(microphoneImageView )
    micStackView.addArrangedSubview(rightButton)


  }

  //  레이아웃 설정
  private func setConstraints() {
    questionStackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(16)
      $0.leading.trailing.equalToSuperview().inset(32)
    }

    verticalBar.snp.makeConstraints {
      $0.width.equalTo(4)
    }

    interviewerImageView.snp.makeConstraints {
      $0.top.equalTo(questionStackView.snp.bottom).offset(12)
      $0.centerX.equalToSuperview()
      $0.height.width.equalTo(100)
    }

    myAnswerLabel.snp.makeConstraints {
      $0.top.equalTo(interviewerImageView.snp.bottom).offset(12)
      $0.leading.trailing.equalToSuperview().inset(16)
    }

    micStackView.snp.makeConstraints {
      $0.top.equalTo(myAnswerLabel.snp.bottom).offset(12)
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(12)
    }

  }
}

