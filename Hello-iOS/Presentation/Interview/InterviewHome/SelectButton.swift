//
//  SelectButton.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/11/25.
//
import UIKit
import SnapKit
import Then

class SelectButton: UIButton {

  let contentStack = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 12
    $0.alignment = .center
    $0.translatesAutoresizingMaskIntoConstraints = false
  }

  private let iconImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.tintColor = .white
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.widthAnchor.constraint(equalToConstant: 50).isActive = true
    $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
  }

  private let iconImageView2 = UIImageView().then {
    $0.image = UIImage(systemName: "chevron.right")
    $0.contentMode = .scaleAspectFit
    $0.tintColor = .white
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.widthAnchor.constraint(equalToConstant: 40).isActive = true
    $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
  }

  private let textStack = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 4
    $0.alignment = .leading
  }

  private let titleLabelView = UILabel().then {
    $0.font = .systemFont(ofSize: 30, weight: .bold)
    $0.textColor = .white
    $0.numberOfLines = 2
  }

  private let subtitleLabelView = UILabel().then {
    $0.font = .systemFont(ofSize: 20, weight: .bold)
    $0.textColor = UIColor.white.withAlphaComponent(0.9)
    $0.numberOfLines = 2
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupStyle()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupStyle()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    applyShadow()
  }

  private func setupStyle() {
    layer.cornerRadius = 15
    clipsToBounds = false

    // 서브뷰가 터치 안 가로채게
    [contentStack, iconImageView, iconImageView2, textStack, titleLabelView, subtitleLabelView]
      .forEach { $0.isUserInteractionEnabled = false }

    addSubview(contentStack)

    contentStack.addArrangedSubview(iconImageView)
    contentStack.addArrangedSubview(textStack)
    contentStack.addArrangedSubview(iconImageView2)

    textStack.addArrangedSubview(titleLabelView)
    textStack.addArrangedSubview(subtitleLabelView)

    contentStack.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview().inset(16)
    }
  }

  private func applyShadow() {
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.2
    layer.shadowOffset = CGSize(width: 0, height: 2)
    layer.shadowRadius = 4
    layer.shadowPath = UIBezierPath(
      roundedRect: bounds,
      cornerRadius: layer.cornerRadius
    ).cgPath
  }

  func configure(title: String, subtitle: String, iconName: String, backgroundColor: UIColor) {
    let attributes: [NSAttributedString.Key: Any] = [
        .strokeColor: UIColor.black,       // 윤곽선 색
        .foregroundColor: UIColor.white,   // 안쪽 글자 색
        .strokeWidth: -1.0                  // 윤곽선 두께 (음수로 해야 채워짐)
    ]
    titleLabelView.attributedText = NSAttributedString(string: title, attributes: attributes)
    subtitleLabelView.attributedText = NSAttributedString(string: subtitle, attributes: attributes)
    iconImageView.image = UIImage(systemName: iconName)
    self.backgroundColor = backgroundColor
  }
}
