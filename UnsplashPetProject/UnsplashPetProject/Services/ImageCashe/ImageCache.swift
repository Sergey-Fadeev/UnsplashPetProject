//
//  ImageCache.swift
//  UnsplashPetProject
//
//  Created by Sergey on 31.10.2023.
//

import SwiftUI
import Foundation

class ImageCache {
  
  static let shared = ImageCache()
  private let cache = NSCache<NSString,UIImage>()
  
  private init() { }
  
  func getImage(for id: String) -> UIImage? {
    return cache.object(forKey: id as NSString)
  }
  
  func setImage(_ image: UIImage, for id: String) {
    cache.setObject(image, forKey: id as NSString)
  }
  
}
