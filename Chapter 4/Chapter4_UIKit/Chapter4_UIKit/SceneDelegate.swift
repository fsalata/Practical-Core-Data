import UIKit
import StorageProvider

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  let storage = StorageProvider()

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

    guard let windowScene = (scene as? UIWindowScene) else { return }

    let tabBarController = UITabBarController()
    let moviesVc = MoviesViewController(storageProvider: storage)
    let importVc = ImportViewController(storageProvider: storage)

    tabBarController.setViewControllers([moviesVc, importVc], animated: true)

    self.window = UIWindow(windowScene: windowScene)
    window?.rootViewController = tabBarController
    window?.makeKeyAndVisible()
  }
}
