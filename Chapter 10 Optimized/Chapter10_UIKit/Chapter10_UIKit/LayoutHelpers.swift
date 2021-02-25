import UIKit

extension UIView {
  func pinToEdges(of view: UIView, useSafeArea: Bool = false, inset: CGFloat = 0) {
    self.translatesAutoresizingMaskIntoConstraints = false

    if useSafeArea {
      NSLayoutConstraint.activate([
        topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: inset),
        leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: inset),
        bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -inset),
        trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -inset)
      ])
    } else {
      NSLayoutConstraint.activate([
        topAnchor.constraint(equalTo: view.topAnchor, constant: inset),
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -inset),
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset)
      ])
    }
  }
}
