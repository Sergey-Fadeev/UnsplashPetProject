//
//  ImageDetailViewModel.swift
//  UnsplashPetProject
//
//  Created by Sergey on 26.10.2023.
//

import SwiftUI
import Combine

class ImageDetailViewModel: ObservableObject {
  
  @Published var columns: [Column] = [Column(), Column()]
  @Published var dataIsLoading = false
  
  
  @Published var imageData = Data()
  @Published var gridItem: GridItem
  
  var isAuthorsImageDetail: Bool
  
  private var currentPage = 0
  private var leftHeight: Double = 0
  private var rightHeight: Double = 0
  
  private var cancellables = Set<AnyCancellable>()
  var networkService: NetworkService
  
  init(networkService: NetworkService, gridItem: GridItem, isAuthorsImageDetail: Bool) {
    self.networkService = networkService
    self.isAuthorsImageDetail = isAuthorsImageDetail
    self.gridItem = gridItem
  }
  
}
