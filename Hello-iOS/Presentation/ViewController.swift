//
//  ViewController.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/6/25.
//

import UIKit
import ReactorKit

class ViewController: BaseViewController<ViewReactor> {

  override func viewDidLoad() {
    super.viewDidLoad()
    print("hello world")
    view.backgroundColor = .red
  }
}
