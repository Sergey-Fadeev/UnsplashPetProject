//
//  InfiniteListViewModel.swift
//  UnsplashPetProject
//
//  Created by Sergey on 09.10.2023.
//

import SwiftUI
import Combine

class InfiniteListViewModel: ObservableObject {
  
  var cancellables = Set<AnyCancellable>()
  
  private let itemsFromEndThreshold = 5
  
  private var downloadingDataIsAvailable: Bool = true
  private var itemsLoadedCount: Int?
  private var currentPage = 0
  
  private var canLoadMorePages = true
  
  @ObservedObject private var networkService: NetworkService = NetworkService.shared
  
  @Published var items: [APIUnsplashItem] = []
  @Published var dataIsLoading = false
  
  func requestInitialSetOfItems() {
    currentPage = 1
    requestItems(page: currentPage)
  }
  /// Used for infinite scrolling. Only requests more items if pagination criteria is met.
  func requestMoreItemsIfNeeded(index: Int) {
    guard let itemsLoadedCount = itemsLoadedCount, downloadingDataIsAvailable else {
      return
    }
    
    if thresholdMeet(itemsLoadedCount, index)  {
      // Request next page
      currentPage += 1
      requestItems(page: currentPage)
    }
  }
  
  private func requestItems(page: Int) {
    Task {
      guard !dataIsLoading && canLoadMorePages else {
        print("vishel")
        
        return
      }
      
      dataIsLoading = true
      
      await networkService.loadMoreContent(page: page)
        .receive(on: RunLoop.main)
        .sink(
          receiveCompletion: { error in
            print("\(error)")
          },
          receiveValue: { [weak self] response in
            guard let self = self, let response = response else {
              return
            }
            
            self.canLoadMorePages = response.hasMorePages
            self.dataIsLoading = false
            
            self.items.append(contentsOf: response.items)
            self.itemsLoadedCount = self.items.count
          }
        )
        .store(in: &cancellables)
    }
  }
  
  /// Determines whether we have meet the threshold for requesting more items.
  private func thresholdMeet(_ itemsLoadedCount: Int, _ index: Int) -> Bool {
    return (itemsLoadedCount - index) == itemsFromEndThreshold
  }
  
}
