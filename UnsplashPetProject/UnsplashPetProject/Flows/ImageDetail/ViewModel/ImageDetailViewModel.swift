//
//  ImageDetailViewModel.swift
//  UnsplashPetProject
//
//  Created by Sergey on 26.10.2023.
//

import SwiftUI
import Combine

class ImageDetailViewModel: ObservableObject {
  
  @Published var gridItem: GridItem
  
  var isAuthorsImageDetail: Bool
  var networkService: NetworkService
  
  init(networkService: NetworkService, gridItem: GridItem, isAuthorsImageDetail: Bool) {
    self.networkService = networkService
    self.isAuthorsImageDetail = isAuthorsImageDetail
    self.gridItem = gridItem
  }
  
}
