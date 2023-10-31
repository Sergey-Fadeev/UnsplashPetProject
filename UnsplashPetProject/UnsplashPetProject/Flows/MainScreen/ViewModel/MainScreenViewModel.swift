//
//  ImageLoaderViewModel.swift
//  UnsplashPetProject
//
//  Created by Sergey on 24.10.2023.
//

import SwiftUI
import Combine

class MainScreenViewModel: ObservableObject {
  
  @Published var columns: [Column] = [Column(), Column()]
  @Published var dataIsLoading = false
  
  private let imageUrlsSubject = CurrentValueSubject<[DomainImageResponse], Never>([])
  
  private var currentPage = 0
  private var leftHeight: Double = 0
  private var rightHeight: Double = 0
  
  private var cancellables = Set<AnyCancellable>()
  var networkService: NetworkService
  
  init(networkService: NetworkService) {
    self.networkService = networkService
    bind()
  }
  
  func requestInitialSetOfItems() {
    dataIsLoading = true
    
    currentPage = 1
    requestItems(page: currentPage)
  }
  
  func requestMoreItemsIfNeeded() {
    guard !dataIsLoading else {
      return
    }
    
    dataIsLoading = true
    currentPage += 1
    requestItems(page: currentPage)
  }
  
  func requestItems(page: Int) {
    networkService.loadImages(page: page)
      .sink(
        receiveCompletion: { error in
          print("\(error)")
        },
        receiveValue: { [weak self] response in
          guard let self = self else {
            return
          }
          
          self.imageUrlsSubject.send(response)
        }
      )
      .store(in: &cancellables)
  }
  
  private func bind() {
    imageUrlsSubject
      .flatMap { [weak self] imagesArray -> AnyPublisher<([Column], [Double]), Never> in
        guard let self = self else {
          return Empty(completeImmediately: false).eraseToAnyPublisher()
        }
        
        let gridItems: [GridItem] = imagesArray.compactMap { response in
          let ratio = Double(response.height) / Double(response.width)
          let width = UIScreen.main.bounds.width - Constants.imageHorizontalPadding * 3 / 2.0
          let height = width * ratio
          
          return GridItem(
            ratio: ratio,
            height: height,
            imageInfo: response, 
            imageCellViewModel: ImageCellViewModel(imageUrlString: response.imageUrls.small)
          )
        }
        
        var columns: [Column] = [Column(), Column()]
        var columnsHeights = [self.leftHeight, self.rightHeight]
        
        for gridItem in gridItems {
          if columnsHeights[0] > columnsHeights[1] {
            columns[1].gridItems.append(gridItem)
            columnsHeights[1] += gridItem.height + Constants.imageSpacing
          } else {
            columns[0].gridItems.append(gridItem)
            columnsHeights[0] += gridItem.height + Constants.imageSpacing
          }
        }
        
        return Just((columns, columnsHeights))
          .eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { error in
          print("\(error)")
        },
        receiveValue: { [weak self] columns, columnsHeights in
          guard let self = self else {
            return
          }
          
          self.dataIsLoading = false
          
          self.columns[0].gridItems += columns[0].gridItems
          self.columns[1].gridItems += columns[1].gridItems
          self.leftHeight = columnsHeights[0]
          self.rightHeight = columnsHeights[1]
        }
      )
      .store(in: &cancellables)
  }
  
}
