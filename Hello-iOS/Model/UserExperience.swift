
import Foundation

// 사용자 경험치 모델
struct UserExperience {
  let exp: Int // 누적 경험치
  
  // 현재 레벨
  var level: Level {
    switch exp {
    case ..<10: return .egg
    case 10..<20: return .chick
    case 20..<30: return .hen
    default: return .phoenix
    }
  }
  
  // 현재 단계의 이미지 에셋 이름
  var imageAssetName: String {
    level.assetName
  }
  
  // 사용자 레벨 단계 enum
  enum Level: Int {
    case egg = 0
    case chick
    case hen
    case phoenix
    
    // 에셋 네임
    var assetName: String {
      switch self {
      case .egg: return "egg"
      case .chick: return "chick"
      case .hen: return "hen"
      case .phoenix: return "phoenix"
      }
    }
    
    // 라벨 텍스트
    var labelText: String {
      switch self {
      case .egg: return "Lv1. Egg"
      case .chick: return "LV2. Chick"
      case .hen: return "Lv3. Hen"
      case .phoenix: return "Lv4. Phoenix"
      }
    }
  }
}

extension UserExperience {
  func expProgressAndLabel() -> (Float, String) {
    let (base, next) = {
      switch self.level {
      case .egg: return (0, 10)
      case .chick: return (10, 20)
      case .hen: return (20, 30)
      case .phoenix: return (30, 30) // 만렙 구간도 40~40으로 고정
      }
    }()
    let expToNext = next - base
    let myExpInStage = exp - base
    
    if self.level == .phoenix {
      // 만렙: 40/40로 고정
      return (1.0, "(30 / 30)")
    }
    let progress = Float(myExpInStage) / Float(expToNext)
    let label = "(\(myExpInStage) / \(expToNext))"
    return (progress, label)
  }
}


