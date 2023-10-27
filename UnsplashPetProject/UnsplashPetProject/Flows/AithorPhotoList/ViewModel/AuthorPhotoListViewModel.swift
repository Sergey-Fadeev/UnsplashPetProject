//
//  AuthorPhotoListViewModel.swift
//  UnsplashPetProject
//
//  Created by Sergey on 27.10.2023.
//

import SwiftUI
import Combine

class AuthorPhotoListViewModel: ObservableObject {
  
  @Published var columns: [Column] = [Column(), Column()]
  @Published var dataIsLoading = false
  
  @Published var error: Error?
  @Published var isShowingError = false
  
  private let imageUrlsSubject = CurrentValueSubject<[APIImageResponse], Never>([])
  
  private var currentPage = 0
  private var leftHeight: Double = 0
  private var rightHeight: Double = 0
  
  private var cancellables = Set<AnyCancellable>()
  var networkService: NetworkService
  var imageInfo: APIImageResponse
  
  init(networkService: NetworkService, imageInfo: APIImageResponse) {
    self.networkService = networkService
    self.imageInfo = imageInfo
    
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
    networkService.loadImages(page: page, username: imageInfo.user?.username)
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] error in
          switch error {
          case .finished:
            break
          case .failure(let failure):
            self?.dataIsLoading = false
            self?.error = .some(failure)
            self?.isShowingError = true
          }
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
      .flatMap { [weak self] imagesArray -> AnyPublisher<[ImageResponseDomain], Error> in
        guard let self = self else {
          return Empty(completeImmediately: false).eraseToAnyPublisher()
        }
        
        return self.networkService.loadImages(responseArray: imagesArray)
      }
      .flatMap { images -> AnyPublisher<([Column], [Double]), Never> in
        let gridItems = images.map { response in
          var ratio: Double = 0
          var height: Double = 0
          
          if response.image.size.height > response.image.size.width {
            ratio = response.image.size.height / response.image.size.width
            height = (UIScreen.main.bounds.width - Constants.imageHorizontalPadding * 3 / 2.0) * ratio
          } else {
            ratio = response.image.size.width / response.image.size.height
            height = UIScreen.main.bounds.width - Constants.imageSpacing * 3 / 2.0
          }
          
          return GridItem(
            ratio: ratio,
            height: height,
            title: response.imageAPIResponse.altDescription ?? "",
            uiImage: response.image,
            imageInfo: response.imageAPIResponse
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
