//
//  InterViewController.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/6/25.
//

import UIKit
import ReactorKit
import Then
import SnapKit

class InterviewViewController: BaseViewController<InterviewReactor> {

  let myStudyInterviewButton = UIButton(type: .system).then {
    $0.setTitle("내 학습 기반 모의 면접", for: .normal)
    $0.backgroundColor = .systemBackground
    $0.layer.cornerRadius = 8
    $0.tintColor = .label
    $0.titleLabel?.font = .systemFont(ofSize: 25, weight: .bold)
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.2
    $0.layer.shadowOffset = CGSize(width: 0, height: 2)
    $0.layer.shadowRadius = 4
  }

  let reviewInterviewButton = UIButton(type: .system).then {
    $0.setTitle("복습 모의 면접", for: .normal)
    $0.backgroundColor = .systemBackground
    $0.layer.cornerRadius = 8
    $0.tintColor = .label
    $0.titleLabel?.font = .systemFont(ofSize: 25, weight: .bold)
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.2
    $0.layer.shadowOffset = CGSize(width: 0, height: 2)
    $0.layer.shadowRadius = 4
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUI()
    setConstraints()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    myStudyInterviewButton.layer.shadowPath = UIBezierPath(
      roundedRect: myStudyInterviewButton.bounds,
      cornerRadius: myStudyInterviewButton.layer.cornerRadius).cgPath

    reviewInterviewButton.layer.shadowPath = UIBezierPath(
      roundedRect: reviewInterviewButton.bounds,
      cornerRadius: reviewInterviewButton.layer.cornerRadius).cgPath
  }

  init(reactor: InterviewReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // UI 추가
  private func setUI() {
    view.addSubview(myStudyInterviewButton)
    view.addSubview(reviewInterviewButton)
  }

  //  레이아웃 설정
  private func setConstraints() {
    myStudyInterviewButton.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.width.equalTo(350)
    }

    reviewInterviewButton.snp.makeConstraints {
      $0.top.equalTo(myStudyInterviewButton.snp.bottom).offset(15)
      $0.centerX.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.width.equalTo(350)
    }
  }
}
