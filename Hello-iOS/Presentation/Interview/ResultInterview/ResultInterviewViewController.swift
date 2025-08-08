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

  // 진행률 컨테이너
  private let progressContainer = UIView().then {
    // 배경색을 투명하게 설정
    $0.backgroundColor = .clear
  }

  // 진행률 원형 링
  private let ring = RingView().then {
    $0.trackColor = .systemGray
    $0.progressColor = .main
    $0.lineWidth = 6
    $0.setCenterText("3/10")
    $0.setProgress(0.3, animated: true)
  }

  // 진행률 라벨
  private let progressLabel = UILabel().then {
    // 텍스트 색상을 메인 컬러로 설정
    $0.textColor = .main
    // 폰트 크기 및 볼드체 설정
    $0.font = .systemFont(ofSize: 20, weight: .bold)
    // 텍스트 중앙 정렬
    $0.textAlignment = .center
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
    view.addSubview(ring)
  }

  //  레이아웃 설정
  private func setConstraints() {
    ring.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
      $0.leading.equalToSuperview().offset(20)
      $0.width.height.equalTo(64)
    }
  }
}

@available(iOS 17.0, *)
#Preview {
  ResultInterviewViewController(reactor: ResultInterviewReactor() )
}
