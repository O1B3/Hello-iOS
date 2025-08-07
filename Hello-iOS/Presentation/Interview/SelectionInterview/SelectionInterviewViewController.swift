//
//  SelectionInterviewViewController.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/7/25.
//
import UIKit
import ReactorKit
import RxCocoa
import Then
import SnapKit

class SelectionInterviewViewController: BaseViewController<SelectionInterviewReactor> {

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setConstraints()
    view.backgroundColor = .blue
  }

  init(reactor: SelectionInterviewReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // UI 추가
  override func setupUI() {

  }

  //  레이아웃 설정
  private func setConstraints() {
  }
}
