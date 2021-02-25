import CoreData
import UIKit
import CoreGraphics

class UIImageTransformer: ValueTransformer {
  static let name = NSValueTransformerName(rawValue: "UIImageTransformer")
  
  override class func transformedValueClass() -> AnyClass {
    return UIImage.self
  }
  
  override class func allowsReverseTransformation() -> Bool {
    true
  }
  
  override func transformedValue(_ value: Any?) -> Any? {
    guard let image = value as? UIImage
    else { return nil }
    
    do {
      let data = try NSKeyedArchiver.archivedData(withRootObject: image, requiringSecureCoding: true)
      return data
    } catch {
      print("Failed to transform UIImage -> Data")
      return nil
    }
  }
  
  override func reverseTransformedValue(_ value: Any?) -> Any? {
    guard let data = value as? Data
    else { return nil }
    
    do {
      let image = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIImage.self, from: data)
      return image
    } catch {
      print("Failed to transform `Data` to `UIImage`")
      return nil
    }
  }
}
