//
//  ShadiwButton.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/7/25.
//
import UIKit

class ShadowButton: UIButton {

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
    backgroundColor = .systemBackground
    setTitleColor(.label, for: .normal)
    tintColor = .label
    titleLabel?.font = .systemFont(ofSize: 25, weight: .bold)
    layer.borderWidth = 1
    layer.borderColor = UIColor.black.cgColor
    clipsToBounds = false
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
}
