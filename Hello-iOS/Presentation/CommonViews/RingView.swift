//
//  RingView.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/8/25.
//
import UIKit

final class RingView: UIView {
  // 링 두께
  var lineWidth: CGFloat = 6 { didSet { updateLayers() } }
  // 배경 트랙 색상
  var trackColor: UIColor = .systemGray4 { didSet { trackLayer.strokeColor = trackColor.cgColor } }
  // 진행 색상
  var progressColor: UIColor = .systemBlue { didSet { progressLayer.strokeColor = progressColor.cgColor } }
  // 현재 진행 값(0.0 ~ 1.0)
  private(set) var progress: CGFloat = 0

  // 배경(전체 원) 레이어
  private let trackLayer = CAShapeLayer()
  // 진행(일부 원) 레이어
  private let progressLayer = CAShapeLayer()

  // 중앙에 표시되는 텍스트(예: "3/10" 또는 "30%")
  let centerLabel = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  private func setup() {
    // 중앙 라벨 기본 설정
    centerLabel.textAlignment = .center
    centerLabel.textColor = .label
    centerLabel.font = .systemFont(ofSize: 16, weight: .medium)
    addSubview(centerLabel)

    // 공통 레이어 속성
    [trackLayer, progressLayer].forEach { layer in
      layer.fillColor = UIColor.clear.cgColor // 내부는 비움
      layer.lineCap = .round // 끝부분 둥글게 처리
      layer.contentsScale = UIScreen.main.scale // 레티나 스케일
    }

    // 색상 초기값
    trackLayer.strokeColor = trackColor.cgColor
    progressLayer.strokeColor = progressColor.cgColor

    // 두께 초기값
    trackLayer.lineWidth = lineWidth
    progressLayer.lineWidth = lineWidth

    // 시작 진행값 0
    progressLayer.strokeEnd = 0

    // 레이어 추가
    layer.addSublayer(trackLayer)
    layer.addSublayer(progressLayer)
  }

  // MARK: - Layout
  override func layoutSubviews() {
    super.layoutSubviews()
    // 오토레이아웃으로 크기가 바뀔 때마다 path 갱신 필요
    updateLayers()

    // 라벨을 뷰 중앙에 배치
    centerLabel.frame = bounds
    centerLabel.isUserInteractionEnabled = false
  }

  override var intrinsicContentSize: CGSize {
    // 기본 사이즈 제공(오토레이아웃에서 사이즈 미지정 시 사용)
    CGSize(width: 64, height: 64)
  }

  // 현재 뷰의 크기에 맞춰 path/두께/프레임을 갱신
  private func updateLayers() {
    // 반지름 = 짧은 변의 절반 - 선 두께의 절반 (선이 잘리지 않도록 보정)
    let radius = max(0, min(bounds.width, bounds.height) / 2 - lineWidth / 2)
    let center = CGPoint(x: bounds.midX, y: bounds.midY)

    // 12시 방향에서 시작해서 시계방향으로 그리기
    let startAngle = -CGFloat.pi / 2
    let endAngle = startAngle + 2 * CGFloat.pi

    let path = UIBezierPath(
      arcCenter: center,
      radius: radius,
      startAngle: startAngle,
      endAngle: endAngle,
      clockwise: true
    )

    trackLayer.path = path.cgPath
    progressLayer.path = path.cgPath

    trackLayer.lineWidth = lineWidth
    progressLayer.lineWidth = lineWidth

    // 레이어 프레임도 현재 bounds로 동기화
    trackLayer.frame = bounds
    progressLayer.frame = bounds
  }

  // - Parameters:
  //   - value: 0 ~ 1 사이 값 이외는 자동 보정
  //   - animated: 애니메이션 여부
  //   - duration: 애니메이션 시간
  func setProgress(_ value: CGFloat, animated: Bool = true, duration: CFTimeInterval = 0.35) {
    // 0~1 범위로 보정
    let clamped = max(0, min(1, value))
    progress = clamped

    if animated {
      // 현재 표시 중인 값(프레젠테이션 레이어가 있으면 그 값을 시작값으로)
      let from = (progressLayer.presentation()?.strokeEnd) ?? progressLayer.strokeEnd
      let to = clamped

      let animation = CABasicAnimation(keyPath: "strokeEnd")
      animation.fromValue = from
      animation.toValue = to
      animation.duration = duration
      animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

      // 최종 값 고정 + 애니메이션 적용
      progressLayer.strokeEnd = to
      progressLayer.add(animation, forKey: "strokeEnd")
    } else {
      progressLayer.strokeEnd = clamped
      progressLayer.removeAnimation(forKey: "strokeEnd")
    }
  }

  /// 중앙 라벨 텍스트 업데이트 (예: "3/10" 혹은 "30%")
  func setCenterText(_ text: String?) {
    centerLabel.text = text
  }
}
