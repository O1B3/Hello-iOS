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

  private func setupShadow() {

    backgroundColor = .clear

    layer.cornerRadius = 12
    layer.masksToBounds = false  // 그림자가 잘리지 않도록

    layer.shadowColor = UIColor.black.cgColor         // 그림자색
    layer.shadowOpacity = 0.2                         // 그림자 투명도
    layer.shadowOffset = CGSize(width: 0, height: 4)  // 그림자 위치
    layer.shadowRadius = 6                            // 블러 정도
  }
}
