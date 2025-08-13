//
//  ShadowView.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/12/25.
//
import UIKit

class ShadowView: UIView {

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupShadow()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupShadow()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    layer.shadowPath = UIBezierPath(
      roundedRect: bounds,
      cornerRadius: layer.cornerRadius
    ).cgPath
  }

  private func setupShadow() {
    layer.cornerRadius = 12                           // 모서리 둥글게
    layer.masksToBounds = false                       // 그림자 안 잘리도록

    layer.shadowColor = UIColor.black.cgColor         // 그림자 색
    layer.shadowOpacity = 0.2                         // 그림자 투명도
    layer.shadowOffset = CGSize(width: 0, height: 4)  // 그림자 위치
    layer.shadowRadius = 4                            // 그림자 블러
  }
}
