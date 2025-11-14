# CoordinatorKit

  CoordinatorKit is a lightweight UIKit coordinator library that wires navigation flows into strongly typed objects. It ships a base coordinator, ready‑made tab and split coordinators, lifecycle hooks, and Combine
  publishers so you can decouple screen flows from view controllers.

  ## Features

  - `BaseCoordinator` for building strongly typed flows with completion callbacks and Combine publishers.
  - `AppCoordinator` singleton for driving the root window and swapping entire flows.
  - Built-in presenters: `TabCoordinator`, (experimental) `SplitCoordinator`, plus modal/push styles.
  - Property wrappers (`Weakify`, `SettableOnce`) to safely manage view controller lifetimes.
  - Presentation utilities (`PresentationController`, `PresentationStyle`) and UIKit helpers.

  ## Requirements

  - iOS 13.0+
  - Swift 5.2+
  - Xcode 12+

  ## Installation

  ### Swift Package Manager

  1. In Xcode, choose *File ▸ Add Packages…*
  2. Enter the repo URL and pick the latest release.
  3. Add `CoordinatorKit` to your target.

  Or add it manually to `Package.swift`:

  ```swift
  .package(url: "https://github.com/<your-org>/CoordinatorKit.git", from: "1.0.0"),

  ## Quick Start

  Create a coordinator by subclassing BaseCoordinator. Specify the key controller it manages (usually UINavigationController) and the data type it emits on completion.

  import CoordinatorKit

  final class LoginCoordinator: BaseCoordinator<UINavigationController, LoginCoordinator.Result> {
      enum Result { case success(User), cancel }

      init() {
          super.init(keyViewController: UINavigationController())
      }

      func start() {
          let screen = LoginViewController()
          screen.onFinish = { [weak self] user in
              self?.complete(data: .success(user))
          }
          presentationController.push(screen, animated: true)
      }
  }

  Present coordinators from your root:

  final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
      var window: UIWindow?

      func scene(_ scene: UIScene,
                 willConnectTo session: UISceneSession,
                 options connectionOptions: UIScene.ConnectionOptions) {
          let window = UIWindow(windowScene: scene as! UIWindowScene)
          AppCoordinator.shared.configure(with: window) { appCoordinator in
              let login = LoginCoordinator()
              appCoordinator.present(coordinator: login, animated: false)

              login.completionPublisher
                  .sink { result in
                      print("Login finished: \(result)")
                  }
                  .store(in: &cancellables)
          }
          self.window = window
      }
  }

  Present child coordinators from within a parent:

  func showProfile() {
      let coordinator = ProfileCoordinator()
      coordinator.completionCallback = { [weak self] action in
          self?.handleProfile(action)
      }
      present(coordinator: coordinator, style: .pushOrModal(
          parameters: .init(navigated: true, presentation: .formSheet)))
  }

  ## Tab and Split Coordinators

  final class MainTabCoordinator: TabCoordinator<Void> {
      func start() {
          let home = HomeCoordinator()
          let settings = SettingsCoordinator()
          setupTabs(coordinators: [home, settings])
          typedViewController.selectedIndex = 0
      }
  }

  SplitCoordinator (iOS 14+) helps you wire primary/secondary flows in a UISplitViewController.

  ## Presentation Styles

  Use PresentationStyle to control how children appear:

  - .push – push on the current navigation stack.
  - .modal(parameters:) – present as a modal, optionally embedding in a navigation controller.
  - .pushOrModal(parameters:) – push when a navigation controller is available, otherwise fall back to modal.

  ModalParameters lets you tweak animation, presentation style, transition style, and custom transitioning delegates.

  ## Combine Integration

  Every coordinator exposes:

  - completionCallback + completionPublisher for delivering results.
  - dismissCallback + dismissPublisher to react when a flow disappears.

  These make it easy to fan out navigation results without tight coupling.

  ## Example App

  The Example/ directory contains an Xcode project demonstrating common setups. Open Example/Example.xcodeproj to explore and tinker.

  ## Contributing

  1. Clone the repo and open Example/Example.xcodeproj.
  2. Implement your feature or fix.
  3. Add tests / update documentation.
  4. Open a pull request.
