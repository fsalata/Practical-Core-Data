//
//  UIImageTransformer.swift
//  Chapter3
//
//  Created by Donny Wals on 02/02/2021.
//

import UIKit
import CoreData

class UIImageTransformer: ValueTransformer {  
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
