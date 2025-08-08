
import UIKit

import FSCalendar
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

import RealmSwift // 테스트용 임포트

final class MyPageInfoViewController: BaseViewController<MyPageInfoReactor>, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
  // 프로필 이미지 뷰
  private let profileImageView = UIImageView().then {
    $0.backgroundColor = .systemGray5
    $0.layer.cornerRadius = 24
    $0.clipsToBounds = true
    $0.contentMode = .scaleAspectFill
  }
  // 레벨 라벨
  private let levelLabel = UILabel().then {
    $0.font = .boldSystemFont(ofSize: 24)
    $0.textAlignment = .center
  }
  // 경험치 바
  private let expBar = UIProgressView(progressViewStyle: .default)
  // 경험치 라벨
  private let expLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 13)
    $0.textAlignment = .center
    $0.textColor = .secondaryLabel
  }
  // 출석 체크 라벨
  private let attendanceLabel = UILabel().then {
    $0.font = .boldSystemFont(ofSize: 24)
    $0.textAlignment = .center
    $0.text = "출석 체크"
  }
  // 캘린더 영역
  private let calendarView = FSCalendar().then {
    // 보편 설정
    $0.locale = Locale(identifier: "ko_KR")
    $0.scrollDirection = .horizontal
    $0.scope = .month
    // 헤더/요일 높이 적당히
    $0.headerHeight = 44
    $0.weekdayHeight = 22
    // 간단한 스타일
    $0.appearance.headerDateFormat = "YYYY년 M월"
    $0.appearance.headerTitleAlignment = .center
    $0.appearance.headerTitleFont = .boldSystemFont(ofSize: 16)
    $0.appearance.headerTitleColor = .label
    $0.appearance.weekdayFont = .systemFont(ofSize: 12, weight: .medium)
    $0.appearance.weekdayTextColor = .label
    $0.appearance.todayColor = .main
    $0.appearance.selectionColor = .correct
    $0.appearance.titlePlaceholderColor = .tertiaryLabel
  }
  
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
    
    // 캘린더 뷰 관련 주입요소
    calendarContainerView.addSubview(calendarView)
    calendarView.dataSource = self
    calendarView.delegate = self
    
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
    
    calendarView.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(8)
    }
    
    recordButton.snp.makeConstraints {
      $0.top.equalTo(calendarContainerView.snp.bottom).offset(24)
      $0.centerX.equalToSuperview()
      $0.height.equalTo(44)
      $0.width.equalTo(200)
      $0.bottom.equalToSuperview().inset(24)
    }
  }
  
  // 달력 레이아웃 호출 리마인드
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tintWeekdayHeader(of: calendarView)
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
    
    reactor.state
      .map(\.attendedDayKeys)
      .distinctUntilChanged()
      .bind(with: self) { user, _ in
        user.calendarView.reloadData()
      }
      .disposed(by: disposeBag)
    
    
    // 탭 진입시 리로드 트리거
    self.rx.viewWillAppear.map { _ in .reloadUserStatus }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    self.rx.viewWillAppear.map { _ in .reloadAttendance }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
}

// MARK: - FSCalendar 날짜 색상, 마킹 관련
extension MyPageInfoViewController {
  func calendar(_ calendar: FSCalendar,
                appearance: FSCalendarAppearance,
                titleDefaultColorFor date: Date) -> UIColor? {
    
    let cal = Calendar(identifier: .gregorian)
    // 이번 달 여부 판단 (currentPage 기준)
    let isInCurrentMonth = cal.isDate(date, equalTo: calendar.currentPage, toGranularity: .month)
    guard isInCurrentMonth else {
      // 이번 달 외 날짜는 회색(placeholder)
      return appearance.titlePlaceholderColor // ex) 사전에 .tertiaryLabel로 지정해둠
    }
    
    // 주말/평일 색
    switch cal.component(.weekday, from: date) {
    case 1:  return .systemRed   // Sun
    case 7:  return .systemBlue  // Sat
    default: return .label       // Mon~Fri
    }
  }
  
  // 요일 헤더 색
  func tintWeekdayHeader(of calendar: FSCalendar) {
    let weekdayView = calendar.calendarWeekdayView
    let labels = weekdayView.weekdayLabels
    guard labels.count == 7 else { return }
    
    func index(forWeekday weekday: Int) -> Int {
      let first = Int(calendar.firstWeekday)
      return ((weekday - first) % 7 + 7) % 7
    }
    
    for lbl in labels { lbl.textColor = .label }
    labels[index(forWeekday: 1)].textColor = .systemRed   // 일
    labels[index(forWeekday: 7)].textColor = .systemBlue  // 토
  }
  
  // 스와이프로 월이 바뀔 때 리로드
  func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
    calendar.reloadData()
    tintWeekdayHeader(of: calendar) // 요일 헤더 라벨도 다시 칠함 (아래 3번)
  }
  
  // 마킹 정보 아래 점을 찍어주는 코드
  func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
    guard let keys = reactor?.currentState.attendedDayKeys else { return 0 }
    return keys.contains(DateKeyService.makeKey(from: date)) ? 1 : 0
  }
  
  // 점 색상 커스텀
  func calendar(_ calendar: FSCalendar,
                appearance: FSCalendarAppearance,
                eventDefaultColorsFor date: Date) -> [UIColor]? {
    guard let keys = reactor?.currentState.attendedDayKeys else { return nil }
    return keys.contains(DateKeyService.makeKey(from: date)) ? [.main] : nil
  }
  
  
  // 마킹 날짜에 원형 색 넣어주는 함수
  func calendar(_ calendar: FSCalendar,
                appearance: FSCalendarAppearance,
                fillDefaultColorFor date: Date) -> UIColor? {
    let cal = Calendar(identifier: .gregorian)
    // 오늘은 main색 마킹이 우선
    if cal.isDateInToday(date) {
      return .main
    }
    // 출석한 날은 sub색 마킹
    if let keys = reactor?.currentState.attendedDayKeys,
       keys.contains(DateKeyService.makeKey(from: date)) {
      return .sub
    }
    // 없으면 마킹 X
    return nil
  }
  
}

//@available(iOS 17.0, *)
//#Preview {
//
//  MyPageInfoViewController(
//    reactor: MyPageInfoReactor(dataService: StubUserDataService())
//  )
//}
