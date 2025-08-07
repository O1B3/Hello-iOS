
import Foundation

// 사용자 경험치 모델
struct UserExperience {
  let exp: Int // 누적 경험치
  
  // 현재 레벨
  var level: Level {
    switch exp {
    case ..<10: return .egg
    case 10..<20: return .chick
    case 20..<40: return .hen
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
      case .egg: return "Egg"
      case .chick: return "Chick"
      case .hen: return "Hen"
      case .phoenix: return "Phoenix"
      }
    }
  }
}
