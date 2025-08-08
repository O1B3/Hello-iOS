
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


// 경험치 관련 값들
extension UserExperience {
  // 경험치 범위
  var expRange: (Int, Int) {
    if level == .phoenix {
      return (30, 30)
    }
    let (base, next) = switch self.level {
    case .egg: (0, 10)
    case .chick: (10, 20)
    case .hen: (20, 30)
    case .phoenix: (30, 30)
    }
    let expToNext = next - base
    let myExpInStage = exp - base
    return (expToNext, myExpInStage)
  }
  
  // 프로그레스바에 보낼 Float 진행도
  var expProgress: Float {
    let (expToNext, myExpInStage) = expRange
    
    let progress = Float(myExpInStage) / Float(expToNext)
    return min(1.0, progress)
  }
  
  // 경험치 상황에 따라 만들어질 라벨 텍스트 -> 만약 다른곳에서 다른 형태로 쓰이는 경우에는 View쪽 이동도 검토해봐야 함.
  var expLabel: String {
    let (expToNext, myExpInStage) = expRange
    let label = "(\(myExpInStage) / \(expToNext))"
    return label
  }
  
}


