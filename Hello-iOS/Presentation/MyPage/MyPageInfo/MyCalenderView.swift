
import UIKit
import FSCalendar
import Then

class MyCalenderView: UIView, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
  
  private let calendarView = FSCalendar().then {
    // 보편 설정
    $0.locale = Locale(identifier: "ko_KR")
    $0.scrollDirection = .horizontal
    $0.scope = .month
    // 헤더/요일 높이 적당히
    $0.headerHeight = 44
    $0.weekdayHeight = 22
    // 스타일 설정
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
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    // 캘린더 뷰 관련 요소 주입
    addSubview(calendarView)
    calendarView.dataSource = self
    calendarView.delegate = self
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    calendarView.frame = bounds           // 내부 크기 지정
    tintWeekdayHeader(of: calendarView)   // 안정성을 위해 레이아웃 잡은 후에 색변경 한번 실행
  }
  
  // 리액터에서 바인딩 되는 값 (출석요일 정보)
  var attendedDayKeys: Set<Date> = [] {
    didSet{
      calendarView.reloadData()
    }
  }
  
  // 요일 색
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
  
  // 요일 헤더 색상 변경
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
    return attendedDayKeys.contains(Calendar.current.startOfDay(for: date)) ? 1 : 0
  }
  
  // 점 색상 커스텀
  func calendar(_ calendar: FSCalendar,
                appearance: FSCalendarAppearance,
                eventDefaultColorsFor date: Date) -> [UIColor]? {
    return attendedDayKeys.contains(Calendar.current.startOfDay(for: date)) ? [.main] : nil
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
    if attendedDayKeys.contains(Calendar.current.startOfDay(for: date)) {
      return .sub
    }
    // 없으면 마킹 X
    return nil
  }
}
