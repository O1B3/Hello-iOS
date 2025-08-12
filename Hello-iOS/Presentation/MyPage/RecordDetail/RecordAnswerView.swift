
import UIKit

final class RecordAnswerView: UIView {
  private let question = UILabel()
  private let model = UILabel()
  private let mine  = UILabel()
  private let stackView = UIStackView()
  private let shadowView = ShadowView()
  
  init(item: MockInterviewRecord) {
    super.init(frame: .zero)
    layer.cornerRadius = 12
    
    [question, model, mine].forEach {
      $0.numberOfLines = 0
      $0.lineBreakMode = .byWordWrapping
    }
    question.font = .systemFont(ofSize: 15, weight: .semibold)
    
    stackView.axis = .vertical
    stackView.spacing = 8
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
    
    addSubview(shadowView)
    addSubview(stackView)
    
    shadowView.snp.makeConstraints{ $0.edges.equalToSuperview() }
    stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
    [question, model, mine].forEach(stackView.addArrangedSubview)

    question.text = "질문 : \n " + item.question
    model.text = "모법 답안 : \n" + item.modelAnswer
    mine.text  = "내 답안 : \n" + item.myAnswer
    
    shadowView.backgroundColor = (item.isSatisfied ? UIColor.correct20 : UIColor.wrong20 )
    
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }

}
