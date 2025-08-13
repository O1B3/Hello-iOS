
import UIKit

import SnapKit
import Then


final class RecordAnswerView: UIView {
  private let question = UILabel().then{
    $0.font = .systemFont(ofSize: 15, weight: .semibold)
    $0.textColor = .black
  }
  private let model = UILabel().then {
    $0.textColor = .black
  }
  private let mine  = UILabel().then {
    $0.textColor = .black
  }
  private let stackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
  }
  
  private let shadowView = ShadowView()
  
  init(item: MockInterviewRecord) {
    super.init(frame: .zero)
    layer.cornerRadius = 12
    
    [question, model, mine].forEach {
      $0.numberOfLines = 0
      $0.lineBreakMode = .byWordWrapping
    }

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
