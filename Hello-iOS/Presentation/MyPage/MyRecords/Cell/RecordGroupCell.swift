
import UIKit

import SnapKit
import Then

final class RecordGroupCell: UICollectionViewCell {
  
  private let titleLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 16, weight: .semibold)
    $0.textColor = .black
  }
  private let textLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 16, weight: .semibold)
    $0.textColor = .black
  }
  private let subtitleLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 14)
    $0.textColor = .systemGray
  }
  
  private let shadowView = ShadowView()
  
  private let cardView = UIView().then { // 실제 배경/코너 전용
    $0.layer.cornerRadius = 12
    $0.layer.masksToBounds = true
    $0.backgroundColor = UIColor.sub20
  }
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    let stackView = UIStackView(arrangedSubviews: [titleLabel, textLabel, subtitleLabel]).then {
      $0.axis = .vertical
      $0.spacing = 4
    }
    
    contentView.addSubview(shadowView)
    shadowView.addSubview(cardView)
    cardView.addSubview(stackView)
    
    contentView.backgroundColor = .clear
    contentView.layer.cornerRadius = 0
    
    shadowView.snp.makeConstraints { $0.edges.equalToSuperview() }         // 그림자 영역
    cardView.snp.makeConstraints { $0.edges.equalToSuperview() }           // 카드가 그림자 위에 꽉 차게
    stackView.snp.makeConstraints { $0.edges.equalToSuperview().inset(12) }    // 인셋
    
    
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(id: String, dateText: String, subtitle: String) {
    titleLabel.text = dateText
    textLabel.text = "모의 면접 결과"
    subtitleLabel.text = subtitle
  }
}

