
import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class MyPageInfoViewController: BaseViewController<MyPageInfoReactor> {
  init(reactor: MyPageInfoReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }
  
  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupUI() {
    view.backgroundColor = .systemOrange
  }
}
