import UIKit
import StorageProvider

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  let storageProvider = StorageProvider(.uikitApp)

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = ViewController(storageProvider: storageProvider)
    self.window = window
    window.makeKeyAndVisible()
  }
}
