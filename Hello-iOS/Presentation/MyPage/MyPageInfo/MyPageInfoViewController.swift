
import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class MyPageInfoViewController: BaseViewController<MyPageInfoReactor> {
  
  // MARK: - UI 컴포넌트 정의
  private let profileImageView = UIImageView().then {
    $0.backgroundColor = .systemGray5 // 임시
    $0.layer.cornerRadius = 20
    $0.clipsToBounds = true
    $0.image = .egg
  }
  private let levelLabel = UILabel().then {
    $0.font = .boldSystemFont(ofSize: 18)
    $0.textAlignment = .center
    $0.text = "Lv.1" // 임시
  }
  private let expBar = UIProgressView(progressViewStyle: .default).then {
    $0.progress = 0.3 // 임시
  }
  private let expLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 15)
    $0.textAlignment = .center
    $0.text = "3 / 10" // 임시
  }
  private let attendanceLabel = UILabel().then {
    $0.font = .boldSystemFont(ofSize: 20)
    $0.textAlignment = .center
    $0.text = "출석 체크"
  }
  private let calendarContainerView = UIView().then {
    $0.backgroundColor = .secondarySystemBackground
    $0.layer.cornerRadius = 16
  }
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
  
  private let scrollView = UIScrollView()
  private let contentView = UIView()
    
  init(reactor: MyPageInfoReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }
  
  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupUI() {
    view.backgroundColor = .systemBackground
    
    view.addSubview(scrollView)
    scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }

    scrollView.addSubview(contentView)
    contentView.snp.makeConstraints {
        $0.edges.equalToSuperview()
        $0.width.equalToSuperview()
    }
    
    [profileImageView, levelLabel, expBar, expLabel, attendanceLabel, calendarContainerView, recordButton].forEach {
      contentView.addSubview($0)
    }
    
    profileImageView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(32)
      $0.centerX.equalToSuperview()
      $0.width.height.equalTo(100)
    }
    
    levelLabel.snp.makeConstraints {
      $0.top.equalTo(profileImageView.snp.bottom).offset(8)
      $0.centerX.equalToSuperview()
    }
    
    expBar.snp.makeConstraints {
      $0.top.equalTo(levelLabel.snp.bottom).offset(12)
      $0.leading.trailing.equalToSuperview().inset(32)
      $0.height.equalTo(10)
    }
    
    expLabel.snp.makeConstraints {
      $0.top.equalTo(expBar.snp.bottom).offset(4)
      $0.centerX.equalToSuperview()
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
}
