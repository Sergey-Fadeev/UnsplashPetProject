//
//  InfiniteListView.swift
//  UnsplashPetProject
//
//  Created by Sergey on 25.10.2023.
//

import SwiftUI

struct ViewOffsetKey: PreferenceKey {
  typealias Value = CGFloat
  static var defaultValue = CGFloat.zero
  static func reduce(value: inout Value, nextValue: () -> Value) {
    value += nextValue()
  }
}

struct GridItem: Identifiable {
  
  let id = UUID()
  let ratio: Double
  let height: Double
  let title: String
  let uiImage: UIImage
  let imageInfo: APIImageResponse
  
}

struct Column: Identifiable {
  
  let id = UUID()
  var gridItems = [GridItem]()
  
}

struct MainScreenView: View {
  
  @ObservedObject var viewModel: MainScreenViewModel
  
  init(
    viewModel: MainScreenViewModel
  ) {
    self.viewModel = viewModel
    viewModel.requestInitialSetOfItems()
  }
  
  var body: some View {
    NavigationView {
      ScrollView(.vertical, showsIndicators: false) {
        HStack(alignment: .top, spacing: Constants.imageSpacing) {
          ForEach(viewModel.columns) { column in
            LazyVStack(spacing: Constants.imageSpacing) {
              ForEach (column.gridItems) { gridItem in
                NavigationLink(destination: ImageDetailView(
                  viewModel: ImageDetailViewModel(
                    networkService: viewModel.networkService,
                    gridItem: gridItem,
                    isAuthorsImageDetail: false
                  )
                )) {
                  Image(uiImage: gridItem.uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                }
              }
              
              GeometryReader { geometry in
                Color.clear.preference(key: ViewOffsetKey.self, value: geometry.frame(in: .named("scrollView")).minY)
              }
              .frame(height: 0)
            }
          }
        }
        .padding(.horizontal, Constants.imageHorizontalPadding)
      }
      .overlay {
        if viewModel.dataIsLoading {
          RoundedRectangle(cornerRadius: 12)
            .fill(Color.white)
            .frame(width: 75, height: 75)
            .opacity(0.8)
          
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
            .scaleEffect(1.5, anchor: .center)
        }
      }
      .coordinateSpace(name: "scrollView")
      .onPreferenceChange(ViewOffsetKey.self) { minY in
        if minY > -150 {
          viewModel.requestMoreItemsIfNeeded()
        }
      }
    }
  }
  
}
