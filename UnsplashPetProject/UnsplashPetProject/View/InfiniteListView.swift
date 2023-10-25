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
  let isVertical: Bool
  let ratio: Double
  let height: Double
  let title: String
  let uiImage: UIImage
  
}

struct Column: Identifiable {
  
  let id = UUID()
  var gridItems = [GridItem]()
  
}

struct InfiniteListView: View {
  
  let spacing: CGFloat
  let horizontalPadding: CGFloat
  
  @State private var image: [Image] = []
  
  @ObservedObject var viewModel: ImageLoaderViewModel
  
  init(
    viewModel: ImageLoaderViewModel,
    spacing: CGFloat = 20,
    horizontalPadding: CGFloat = 20
  ) {
    self.spacing = spacing
    self.horizontalPadding = horizontalPadding
    
    self.viewModel = viewModel
    viewModel.bind()
    viewModel.requestInitialSetOfItems()
  }
  
  var body: some View {
    ScrollView {
      HStack(alignment: .top, spacing: spacing) {
        ForEach(viewModel.columns) { column in
          LazyVStack(spacing: spacing) {
            ForEach (column.gridItems) { gridItem in
              ListImageRowItem(item: .constant(gridItem), isLoading: .constant(true))
            }
            
            GeometryReader { geometry in
              Color.clear.preference(key: ViewOffsetKey.self, value: geometry.frame(in: .named("scrollView")).minY)
            }
            .frame(height: 0)
          }
        }
      }
      .padding(.horizontal, horizontalPadding)
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
