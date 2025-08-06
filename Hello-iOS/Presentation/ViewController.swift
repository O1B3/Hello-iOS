//
//  ViewController.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/6/25.
//

import UIKit
import ReactorKit
import Then
import SnapKit

class ViewController: BaseViewController<ViewReactor> {

  override func viewDidLoad() {
    super.viewDidLoad()
    print("hello world")
    view.backgroundColor = .red
  }
  init(reactor: ViewReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
