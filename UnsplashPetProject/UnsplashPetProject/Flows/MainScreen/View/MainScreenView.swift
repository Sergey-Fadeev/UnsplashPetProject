//
//  InfiniteListView.swift
//  UnsplashPetProject
//
//  Created by Sergey on 25.10.2023.
//

import SwiftUI

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
      VStack {
        Text("Unsplash")
          .font(.system(size: 36))
          .bold()
        
        Spacer()
        
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
                    let width = (UIScreen.main.bounds.width - Constants.imageSpacing * 3) / 2.0
                    
                    ImageCellView(viewModel: gridItem.imageCellViewModel)
                      .frame(width: width, height: width * gridItem.ratio, alignment: .center)
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
        .coordinateSpace(name: "scrollView")
        .onPreferenceChange(ViewOffsetKey.self) { minY in
          if minY > -150 {
            viewModel.requestMoreItemsIfNeeded()
          }
        }
      }
    }
  }
  
}

struct ViewOffsetKey: PreferenceKey {
  typealias Value = CGFloat
  static var defaultValue = CGFloat.zero
  static func reduce(value: inout Value, nextValue: () -> Value) {
    value += nextValue()
  }
}
