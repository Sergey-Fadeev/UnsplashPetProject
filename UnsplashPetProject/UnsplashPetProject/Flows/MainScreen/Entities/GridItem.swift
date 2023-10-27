//
//  GridItem.swift
//  UnsplashPetProject
//
//  Created by Sergey on 27.10.2023.
//

import Foundation
import SwiftUI

struct GridItem: Identifiable {
  let id = UUID()
  let ratio: Double
  let height: Double
  let title: String
  let uiImage: UIImage
  let imageInfo: DomainImageResponse
}
