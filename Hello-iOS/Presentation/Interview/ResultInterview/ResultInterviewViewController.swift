//
//  ResultInterviewViewController.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/7/25.
//
import UIKit
import ReactorKit
import RxCocoa
import Then
import SnapKit

class ResultInterviewViewController: BaseViewController<ResultInterviewReactor> {

  // 진행 상황 스택 뷰
  private let processStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 8
    $0.distribution = .fillEqually
  }
  // 진행률 원형 링
  private let ring = RingView().then {
    $0.trackColor = .systemGray
    $0.progressColor = .main
    $0.lineWidth = 6
    $0.setCenterText("3/10")
    $0.setProgress(0.3, animated: true)
  }

  private let textStackView = UIStackView().then {
    $0.axis = .vertical
    $0.distribution = .fillEqually

    $0.spacing = 10
  }

  private let contentStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.distribution = .fill
    $0.spacing = 5
  }

  private let contentTitle = UILabel().then {
    $0.textColor = .correct
    $0.font = .systemFont(ofSize: 22, weight: .bold)
    $0.text = "만    족 : "
    $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
  }

  private let contentText = UILabel().then {
    $0.textColor = .correct
    $0.font = .systemFont(ofSize: 22, weight: .bold)
    $0.text = "3"
  }

  private let wrongStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.distribution = .fill
    $0.spacing = 5
  }

  private let wrongTitle = UILabel().then {
    $0.textColor = .wrong
    $0.font = .systemFont(ofSize: 22, weight: .bold)
    $0.text = "불만족 : "
    $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
  }

  private let wrongText = UILabel().then {
    $0.textColor = .wrong
    $0.font = .systemFont(ofSize: 22, weight: .bold)
    $0.text = "0"
  }



  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setConstraints()
  }

  init(reactor: ResultInterviewReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // UI 추가
  override func setupUI() {
    view.addSubview(processStackView)
    processStackView.addArrangedSubview(ring)
    processStackView.addArrangedSubview(textStackView)

    textStackView.addArrangedSubview(contentStackView)
    textStackView.addArrangedSubview(wrongStackView)

    contentStackView.addArrangedSubview(contentTitle)
    contentStackView.addArrangedSubview(contentText)

    wrongStackView.addArrangedSubview(wrongTitle)
    wrongStackView.addArrangedSubview(wrongText)
  }

  //  레이아웃 설정
  private func setConstraints() {
    processStackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(16)
      $0.leading.trailing.equalToSuperview().inset(16)
    }

    ring.snp.makeConstraints {
      $0.width.height.equalTo(100)
    }
  }
}

  @available(iOS 17.0, *)
  #Preview {
    ResultInterviewViewController(reactor: ResultInterviewReactor() )
  }
