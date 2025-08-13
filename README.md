# 😁01B3: Hello-iOS
<img width="360" height="360" alt="image" src="https://github.com/user-attachments/assets/2c2835bc-2251-41cd-9a8e-708436b1ccfd" />

## ✨ 소개 (Introduction)

`Hello-iOS`는 iOS 개발자 기술 면접을 준비하는 사용자를 위한 맞춤형 학습 및 모의 면접 앱입니다. 사용자는 CS 주요 개념을 학습하고, 자신의 학습 상태에 기반한 모의 면접을 통해 실전 감각을 기를 수 있습니다.

---

## 🚀 주요 기능 (Key Features)

### 📖 단어장 & 개념 학습
- **데이터 동기화**: Supabase 백엔드로부터 CS 개념, 질문, 답변 데이터를 받아와 Realm 로컬 데이터베이스에 동기화합니다.
- **학습 진행도 표시**: 카테고리별로 얼마나 많은 개념을 학습했는지 진행도를 시각적으로 보여줍니다.
- **플래시카드 학습**: Tinder와 유사한 스와이프 방식의 UI를 통해 개념을 학습합니다. 오른쪽으로 스와이프하면 '외웠어요'(`isMemory=true`), 왼쪽으로 스와이프하면 '다음에'로 처리되어 학습 상태가 Realm DB에 저장됩니다.

### 🎙️ 모의 면접
- **내 학습 기반 모의 면접**: 사용자가 '외웠어요'로 표시한 개념들 중에서 랜덤으로 최대 10개의 질문이 출제됩니다. 이를 통해 학습한 내용을 확실히 다질 수 있습니다.
- **복습 모의 면접**: 이전 모의 면접에서 '불만족'으로 평가했던 질문들만 모아서 다시 면접을 볼 수 있습니다.
- **음성인식 답변**: iOS의 Speech Framework를 사용하여 사용자의 음성 답변을 텍스트로 변환하여 기록합니다.

### 📈 결과 및 피드백
- **결과 리뷰**: 모의 면접 종료 후, 각 질문에 대한 모범 답안과 자신의 답변을 비교하며 스스로 '만족'/'불만족'을 평가할 수 있습니다.
- **결과 저장**: 평가 결과는 Realm DB에 저장되어 '복습 모의 면접'에 활용됩니다.

### 👤 마이페이지
- **성장 레벨**: 학습 및 면접 활동에 따라 경험치(EXP)가 쌓이고, `알` → `병아리` → `닭` → `피닉스` 순으로 레벨이 오르는 것을 시각적으로 확인할 수 있습니다.
- **출석 체크**: 일일 출석 현황을 캘린더를 통해 확인할 수 있습니다.
- **모의 면접 기록 일람** : 자신이 실행한 모의 면접의 기록을 조회/삭제 할 수 있습니다.

---

## 🛠️ 기술 스택 및 아키텍처 (Tech Stack & Architecture)

- **Architecture**: `ReactorKit`을 기반으로 한 MVVM
- **UI**: `UIKit` (Programmatic UI), `SnapKit`, `Then`
- **Asynchronous**: `RxSwift`, `RxCocoa`
- **Database**: `Realm` (Local), `Supabase` (Remote)
- **Dependency Injection**: Custom DI Container
- **Speech Recognition**: `Speech`
- **Etc**: `FSCalendar`

---

## ⚙️ 실행 방법 (Getting Started)

1.  Repository를 클론합니다.
    ```bash
    git clone https://github.com/your-repository-url/Hello-iOS.git
    ```
2.  프로젝트 루트에 `SUPABASE_URL`과 `SUPABASE_API_KEY`를 포함한 설정 파일(예: `Config.xcconfig`)을 추가해야 합니다.
3.  Xcode로 프로젝트를 열고 필요한 패키지를 설치합니다. (e.g., Swift Package Manager)
4.  빌드 후 실행합니다.

---

## 📂 프로젝트 구조 (Project Structure)

```
Hello-iOS
├── App/         # AppDelegate, SceneDelegate, DIContainer
├── Base/        # BaseViewController, BaseReactor
├── Extensions/  # 확장 기능
├── Model/       # 데이터 모델 (Domain, Realm)
├── Presentation/  # 화면(View)과 관련된 파일
│   ├── CommonViews/ # 공통 UI 컴포넌트
│   ├── Interview/   # 모의 면접 기능
│   ├── MyPage/      # 마이페이지 기능
│   └── WordBook/    # 단어장 및 학습 기능
├── Repositories/  # 데이터 영속성 관리 (Realm, Supabase)
├── Resources/     # Asset, Info.plist 등 리소스 파일
└── Services/      # 비즈니스 로직 서비스
```
