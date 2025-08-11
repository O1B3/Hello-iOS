
import UIKit

final class RecordAnswerView: UIView {
  private let title = UILabel()
  private let model = UILabel()
  private let mine  = UILabel()
  private let stack = UIStackView()
  
  init(item: MockInterviewRecord) {
    super.init(frame: .zero)
    layer.cornerRadius = 12
    clipsToBounds = true
    
    [title, model, mine].forEach {
      $0.numberOfLines = 0
      $0.lineBreakMode = .byWordWrapping
    }
    title.font = .systemFont(ofSize: 15, weight: .semibold)
    
    stack.axis = .vertical
    stack.spacing = 8
    stack.isLayoutMarginsRelativeArrangement = true
    stack.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
    
    addSubview(stack)
    stack.snp.makeConstraints { $0.edges.equalToSuperview() }
    [title, model, mine].forEach(stack.addArrangedSubview)

    title.text = "Q. " + item.question
    model.text = item.modelAnswer
    mine.text  = item.myAnswer
    backgroundColor = (item.isSatisfied ? UIColor.correct : UIColor.wrong )
      .withAlphaComponent(0.20)
    
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }

}
