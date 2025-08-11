
import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class RecordDetailViewController: BaseViewController<RecordDetailReactor> {
  
  private let scrollView = UIScrollView()
  private let stackView = UIStackView()
  
  init(reactor: RecordDetailReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupUI() {
    view.backgroundColor = .systemBackground
    navigationItem.title = "기록 상세"
    
    view.addSubview(scrollView)
    scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
    
    scrollView.addSubview(stackView)
    stackView.axis = .vertical
    stackView.spacing = 12
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = .init(top: 16, left: 16, bottom: 24, right: 16)
    stackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.width.equalTo(scrollView.frameLayoutGuide)
    }
  }
  
  override func bind(reactor: RecordDetailReactor) {
    
    reactor.state.subscribe(onNext: { [weak self] state in
      guard let self else { return }
      for item in state.items {
        let view = RecordAnswerView(item: item)
        stackView.addArrangedSubview(view)
      }
    })
    .disposed(by: disposeBag)
  }
  
}


