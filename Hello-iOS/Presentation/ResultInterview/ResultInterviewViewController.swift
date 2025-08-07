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

  override func viewDidLoad() {
    super.viewDidLoad()
    setUI()
    setConstraints()
    view.backgroundColor = .black
  }

  init(reactor: ResultInterviewReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // UI 추가
  private func setUI() {

  }

  //  레이아웃 설정
  private func setConstraints() {
  }
}
