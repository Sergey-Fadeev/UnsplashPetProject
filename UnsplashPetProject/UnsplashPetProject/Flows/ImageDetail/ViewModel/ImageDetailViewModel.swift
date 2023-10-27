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
  
  
  private var currentPage = 0
  private var leftHeight: Double = 0
  private var rightHeight: Double = 0
  
  private var cancellables = Set<AnyCancellable>()
  var networkService: NetworkService
  
  init(networkService: NetworkService, gridItem: GridItem) {
    self.networkService = networkService
    self.gridItem = gridItem
    
    bind()
  }
  
  private func bind() {
    networkService.loadImage(urlString: gridItem.imageInfo.imageUrls.regular)
      .eraseToAnyPublisher()
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { error in
          print("\(error)")
        },
        receiveValue: { [weak self] imageData in
          guard let self = self else {
            return
          }
          
          self.imageData = imageData
        }
      )
      .store(in: &cancellables)
  }
  
}
