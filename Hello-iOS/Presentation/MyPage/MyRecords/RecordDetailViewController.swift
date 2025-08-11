
import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class RecordDetailViewController: BaseViewController<RecordDetailReactor> {

  init(reactor: RecordDetailReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
