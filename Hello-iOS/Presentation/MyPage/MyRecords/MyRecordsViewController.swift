
import Foundation
import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class MyRecordsViewController: BaseViewController<MyRecordsReactor> {
  init(reactor: MyRecordsReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }
  
  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupUI() {
    view.backgroundColor = .systemOrange
    title = "모의 면접 기록"
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "초기화",
      style: .plain,
      target: nil,
      action: nil
    )
    

  }
}
