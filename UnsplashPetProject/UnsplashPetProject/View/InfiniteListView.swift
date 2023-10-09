//
//  InfiniteListView.swift
//  UnsplashPetProject
//
//  Created by Sergey on 09.10.2023.
//

import SwiftUI

struct InfiniteListView: View {
  
  @ObservedObject var viewModel: InfiniteListViewModel
  
  init(viewModel: InfiniteListViewModel) {
    self.viewModel = viewModel
    viewModel.requestInitialSetOfItems()
  }
  
  var body: some View {
    let items = $viewModel.items.enumerated().map { $0 }
    
    List(items, id: \.element.id) { index, item in
      ListItemRowView(item: item)
        .onAppear {
          viewModel.requestMoreItemsIfNeeded(index: index)
        }
    }
    .overlay {
      if viewModel.dataIsLoading {
        ProgressView()
      }
    }
  }
  
}

//#Preview {
//  InfiniteListView()
//}
