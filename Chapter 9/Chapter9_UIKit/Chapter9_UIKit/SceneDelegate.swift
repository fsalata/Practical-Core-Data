import UIKit
import StorageProvider

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  let storageProvider = StorageProvider()

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

    guard let windowScene = (scene as? UIWindowScene) else { return }

    let albumsVC = AlbumsOverviewViewController(storageProvider: storageProvider)
    let navVC = UINavigationController(rootViewController: albumsVC)
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = navVC
    window.makeKeyAndVisible()

    self.window = window
  }
}

