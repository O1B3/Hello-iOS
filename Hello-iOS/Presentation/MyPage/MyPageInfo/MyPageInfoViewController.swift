
import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

import RealmSwift // 테스트용 임포트

final class MyPageInfoViewController: BaseViewController<MyPageInfoReactor> {
  // 프로필 이미지 뷰
  private let profileImageView = UIImageView().then {
    $0.backgroundColor = .systemGray5
    $0.layer.cornerRadius = 24
    $0.clipsToBounds = true
    $0.contentMode = .scaleAspectFill
    //    $0.image = .egg
  }
  // 레벨 라벨
  private let levelLabel = UILabel().then {
    $0.font = .boldSystemFont(ofSize: 24)
    $0.textAlignment = .center
    //    $0.text = "Lv.1" // 임시
  }
  // 경험치 바
  private let expBar = UIProgressView(progressViewStyle: .default)
  // 경험치 라벨
  private let expLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 13)
    $0.textAlignment = .center
    //    $0.text = "(3 / 10)" // 임시
    $0.textColor = .secondaryLabel
  }
  // 출석 체크 라벨
  private let attendanceLabel = UILabel().then {
    $0.font = .boldSystemFont(ofSize: 24)
    $0.textAlignment = .center
    $0.text = "출석 체크"
  }
  // 캘린더 영역
  private let calendarContainerView = UIView().then {
    $0.backgroundColor = .secondarySystemBackground
    $0.layer.cornerRadius = 16
  }
  // 모의면접 기록 버튼
  private let recordButton = UIButton(configuration: .filled()).then {
    $0.configuration?.title = "모의 면접 기록"
    $0.configuration?.baseBackgroundColor = .main
    $0.configuration?.background.cornerRadius = 8
    $0.configuration?.titleTextAttributesTransformer = .init { attr in
      var newAttr = attr
      newAttr.font = UIFont.systemFont(ofSize: 15, weight: .medium)
      newAttr.foregroundColor = .white
      return newAttr
    }
  }
  
  // 스크롤 뷰
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  
  // 스택뷰 관련
  // 전체 스택뷰
  private let infoStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 25
    $0.alignment = .bottom
  }
  
  // 프로필 우측 영역
  private let infoRowStackView = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .center
    $0.spacing = 8
  }
  
  // 경험치 바 + 경험치 라벨
  private let expBarExpLabelStack = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .fill
    $0.spacing = 2
  }
  
  init(reactor: MyPageInfoReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }
  
  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupUI() {
    
    // 스크롤뷰 최우선 주입
    view.addSubview(scrollView)
    scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
    
    scrollView.addSubview(contentView)
    contentView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.width.equalToSuperview()
    }
    
    // 스택뷰 주입
    expBarExpLabelStack.addArrangedSubview(expBar)
    expBarExpLabelStack.addArrangedSubview(expLabel)
    
    infoStackView.addArrangedSubview(infoRowStackView)
    
    
    // 컨텐츠 뷰에 주입
    contentView.addSubview(profileImageView)
    contentView.addSubview(levelLabel)
    contentView.addSubview(expBarExpLabelStack)
    contentView.addSubview(attendanceLabel)
    contentView.addSubview(calendarContainerView)
    contentView.addSubview(recordButton)
    
    // 오토레이아웃 영역
    profileImageView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(32)
      $0.leading.equalToSuperview().inset(20)
      $0.width.height.equalTo(128)
    }
    
    levelLabel.snp.makeConstraints{
      $0.centerY.equalTo(profileImageView)
      $0.leading.equalTo(profileImageView.snp.trailing).offset(25)
      $0.trailing.equalToSuperview().inset(20)
    }
    
    expBarExpLabelStack.snp.makeConstraints{
      $0.leading.trailing.equalTo(levelLabel)
      $0.bottom.equalTo(profileImageView)
    }
    
    expBar.snp.makeConstraints {
      $0.height.equalTo(10)
    }
    
    attendanceLabel.snp.makeConstraints{
      $0.top.equalTo(expLabel.snp.bottom).offset(16)
      $0.centerX.equalToSuperview()
    }
    
    calendarContainerView.snp.makeConstraints {
      $0.top.equalTo(attendanceLabel.snp.bottom).offset(10)
      $0.leading.trailing.equalToSuperview().inset(20)
      $0.height.equalTo(300)
    }
    
    recordButton.snp.makeConstraints {
      $0.top.equalTo(calendarContainerView.snp.bottom).offset(24)
      $0.centerX.equalToSuperview()
      $0.height.equalTo(44)
      $0.width.equalTo(200)
      $0.bottom.equalToSuperview().inset(24)
    }
  }
  
  override func bind(reactor: MyPageInfoReactor) {
    
    // State -> UI 바인딩
    reactor.state
      .compactMap(\.userExp?.imageAssetName)
      .distinctUntilChanged()
      .bind { [weak self] assetName in
        self?.profileImageView.image = UIImage(named: assetName)
      }
      .disposed(by: disposeBag)
    
    reactor.state.compactMap(\.userExp?.level.labelText)
      .distinctUntilChanged()
      .bind(to: levelLabel.rx.text)
      .disposed(by: disposeBag)
    
    reactor.state.compactMap(\.userExp?.expProgress)
      .distinctUntilChanged()
      .bind(to: expBar.rx.progress)
      .disposed(by: disposeBag)
    
    reactor.state.compactMap(\.userExp?.expLabel)
      .distinctUntilChanged()
      .bind(to: expLabel.rx.text)
      .disposed(by: disposeBag)
    
    // 탭 진입시 리로드 트리거
    self.rx.viewWillAppear.map { _ in .reloadUserStatus }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
}

//@available(iOS 17.0, *)
//#Preview {
//
//  MyPageInfoViewController(
//    reactor: MyPageInfoReactor(dataService: StubUserDataService())
//  )
//}
