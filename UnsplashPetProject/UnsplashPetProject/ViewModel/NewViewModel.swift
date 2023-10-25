//
//  NewViewModel.swift
//  UnsplashPetProject
//
//  Created by Sergey on 24.10.2023.
//

import SwiftUI
import WaterfallGrid
import Combine

class ImageLoaderViewModel: ObservableObject {
  var cancellables = Set<AnyCancellable>()
  
  private let itemsFromEndThreshold = 0
  
  private var downloadingDataIsAvailable: Bool = true
  private var itemsLoadedCount: Int?
  private var currentPage = 0
  
  private var canLoadMorePages = true
  
  @ObservedObject private var networkService: NetworkService = NetworkService.shared
  
  @Published var items: [APIUnsplashItem] = []
  @Published var dataIsLoading = false
  
  
  
  @Published var imageUrls: [APIImageResponse] = []
  @Published var imageList: [Image] = []
  
  @Published var domainImageList: [ImageResponseDomain] = []
  
  let imageUrlsSubject = CurrentValueSubject<[APIImageResponse], Never>([])
  
  
  
  @Published var images: [UIImage] = []
  
  
  @Published var columns: [Column] = [Column(), Column()]
  var leftHeight: Double = 0
  var rightHeight: Double = 0
  
  
  func requestInitialSetOfItems() {
    currentPage = 1
    requestItems(page: currentPage)
    
    print("вызван requestInitial")
  }
  /// Used for infinite scrolling. Only requests more items if pagination criteria is met.
  func requestMoreItemsIfNeeded() {
    
    
    guard downloadingDataIsAvailable else {
      return
    }
    
    print("вызван requestMoreItems")
    
    downloadingDataIsAvailable = false
    
    currentPage += 1
    requestItems(page: currentPage)
  }
  
  
  
  func requestItems(page: Int) {
    guard !dataIsLoading && canLoadMorePages else {
      return
    }
    
    dataIsLoading = true
    
    //      await networkService.loadMoreContent(page: page)
    //        .receive(on: RunLoop.main)
    //        .sink(
    //          receiveCompletion: { error in
    //            print("\(error)")
    //          },
    //          receiveValue: { [weak self] response in
    //            guard let self = self, let response = response else {
    //              return
    //            }
    //
    //            self.canLoadMorePages = response.hasMorePages
    //            self.dataIsLoading = false
    //
    //            self.items.append(contentsOf: response.items)
    //            self.itemsLoadedCount = self.items.count
    //          }
    //        )
    //        .store(in: &cancellables)
    
    
    
    print("количество pages в requestItems - \(page)")
    
    networkService.loadImages(page: page)
      .receive(on: RunLoop.main)
      .sink(
        receiveCompletion: { error in
          print("\(error)")
        },
        receiveValue: { [weak self] response in
          guard let self = self else {
            return
          }
          
          
          
          self.imageUrls += response.map { $0 }
        
          
          self.imageUrlsSubject.send(response)
          
          print("imageUrls.count = \(imageUrls.count)")
        }
      )
      .store(in: &cancellables)
    
    
  }
  
  func bind() {
    imageUrlsSubject
      .flatMap { [weak self] imagesArray -> AnyPublisher<[ImageResponseDomain], Error> in
        guard let self = self else {
          return Empty(completeImmediately: false).eraseToAnyPublisher()
        }
        
        return self.networkService.loadImages(responseArray: imagesArray)
      }
      .receive(on: RunLoop.main)
      .sink(
        receiveCompletion: { error in
          print("\(error)")
        },
        receiveValue: { [weak self] images in
          guard let self = self else {
            return
          }
          
          self.dataIsLoading = false
          
          let gridItems = images.map { response in
            var isVertical: Bool = true
            var ratio: Double = 0
            var height: Double = 0
            
            if response.image.size.height > response.image.size.width {
              isVertical = true
              ratio = response.image.size.height / response.image.size.width
              height = ((UIScreen.main.bounds.width - 60.0) / 2.0) * ratio
            } else {
              isVertical = false
              ratio = response.image.size.width / response.image.size.height
              height = (UIScreen.main.bounds.width - 60.0) / 2.0
            }
            
            return GridItem(
              isVertical: isVertical,
              ratio: ratio,
              height: height,
              title: response.imageAPIResponse.altDescription ?? "",
              uiImage: response.image
            )
          }
          
          var columns: [Column] = [Column(), Column()]
          var columnsHeights = [self.leftHeight, self.rightHeight]
          
          for gridItem in gridItems {
            if columnsHeights[0] > columnsHeights[1] {
              columns[1].gridItems.append(gridItem)
              columnsHeights[1] += gridItem.height
            } else {
              columns[0].gridItems.append(gridItem)
              columnsHeights[0] += gridItem.height
            }
            
            
          }
          
          self.columns[0].gridItems += columns[0].gridItems
          self.columns[1].gridItems += columns[1].gridItems
          self.leftHeight = columnsHeights[0]
          self.rightHeight = columnsHeights[1]
          
          self.downloadingDataIsAvailable = true
        }
      )
      .store(in: &cancellables)
  }
  
}
