//
//  SceneDelegate.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/6/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  
  func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = makeTabBarController()
    window?.makeKeyAndVisible()

    registerObjects()
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = makeTabBarController()
    window?.makeKeyAndVisible()
    updateRecentlyData()
  }
  
  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }
  
  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }
  
  
}

extension SceneDelegate {
  func makeTabBarController() -> UITabBarController {
    let container = DIContainer.shared
    container.register(WordLearningViewController())

    // 면접 VC
    container.register(ResultInterviewViewController(reactor: ResultInterviewReactor()))
    container.register(InterviewRoomViewController(reactor: InterviewRoomReactor()))
    container.register(SelectionInterviewViewController(reactor: SelectionInterviewReactor()))
    container
      .register(InterviewViewController(reactor: InterviewReactor(realmService: RealmService()))
      )
    container.register(WordBookReactor(realmService: RealmService()))
    container.register(WordBookViewController(reactor: container.resolve()))

#if DEBUG
    container
      .register(
        MyPageInfoViewController(reactor: MyPageInfoReactor(dataService: StubUserDataService()))
      )
    container.register(StubRecordDataService() as RecordDataServiceProtocol)
#else
    container
      .register(
        MyPageInfoViewController(reactor: MyPageInfoReactor(dataService: FetchUserDataService()))
      )
    container.register(RealmRecordDataService() as RecordDataServiceProtocol)
#endif
    
    let interviewVC: InterviewViewController = container.resolve()
    let myPageVC: MyPageInfoViewController = container.resolve()
    
    let wordBookVC: WordBookViewController = container.resolve()
    let tabBarController = UITabBarController()
    
    wordBookVC.tabBarItem = UITabBarItem(
      title: "단어장",
      image: UIImage(systemName: "book"),
      tag: 0
    )
    
    interviewVC.tabBarItem = UITabBarItem(
      title: "면접보기",
      image: UIImage(systemName: "magnifyingglass"),
      tag: 1
    )
    
    myPageVC.tabBarItem = UITabBarItem(
      title: "마이페이지",
      image: UIImage(systemName: "person"),
      tag: 2
    )
    
    tabBarController.viewControllers = [wordBookVC, interviewVC, myPageVC].map {
      UINavigationController(rootViewController: $0)
    }
    tabBarController.tabBar.tintColor = .main
    
    /// 하단 탭바의 경계션 표현
    let appearance = UITabBarAppearance()
    
    appearance.configureWithOpaqueBackground()
    appearance.shadowColor = .lightGray
    tabBarController.tabBar.standardAppearance = appearance
    tabBarController.tabBar.scrollEdgeAppearance = tabBarController.tabBar.standardAppearance
    
    /// 상단 네비게이션의 경계션 표현
    let topAppearance = UINavigationBarAppearance()
    
    topAppearance.configureWithOpaqueBackground()
    topAppearance.backgroundColor = .background
    topAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
    topAppearance.shadowColor = UIColor.lightGray
    
    UINavigationBar.appearance().standardAppearance = topAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = topAppearance
    UINavigationBar.appearance().tintColor = .main

    return tabBarController
  }

  func registerObjects() {
    let container = DIContainer.shared

    // WordLearning
    container.register(type: LearningRepositoryProtocol.self, LearningRepository())
    container.register(LearningService(learningRepository: container.resolve()))
    container.register(WordLearningViewController())

    // WordBook
    container.register(WordBookReactor(realmService: RealmService()))
    container.register(WordBookViewController(reactor: container.resolve()))
  }

  func updateRecentlyData() {
    let container = DIContainer.shared
    let learningService: LearningService = container.resolve()

    Task {
      do {
        // 업데이트 필요 여부 확인
        if try await learningService.isUpdateNeeded() {
          // 데이터 업데이트 작업
          /// 최신 데이터 요청
          let recentlyData = try await learningService.requestRecentlyData()
          /// 데이터 저장
          saveData(data: recentlyData)
          /// 데이터 갱신시간 등록
          learningService.setLatestUpdateTimeNow()
        }
      } catch {
        print("⚠️ SceneDelegate 데이터 업데이트 오류: \(error)")
      }
    }
  }

  func saveData(data: [Categories]) {
    let realmService = RealmService()
    let domainData = data.map { RealmCategory(from: $0.toDomain()) }

    do {
      try realmService.upsert(domainData)
    } catch {
      print("⚠️ SceneDelegate upsert 오류: \(error)")
    }
  }
}
