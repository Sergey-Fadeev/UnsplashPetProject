//
//  InfiniteListView.swift
//  UnsplashPetProject
//
//  Created by Sergey on 09.10.2023.
//

//import SwiftUI
//import WaterfallGrid
//import Combine
//
//struct InfiniteListView: View {
//  
//  let detector: CurrentValueSubject<CGFloat, Never>
//  let publisher: AnyPublisher<CGFloat, Never>
//  
//  @ObservedObject var viewModel: InfiniteListViewModel
//  
//  init(viewModel: InfiniteListViewModel) {
//    self.viewModel = viewModel
//    viewModel.requestInitialSetOfItems()
//    
//    let detector = CurrentValueSubject<CGFloat, Never>(0)
//    
//    self.publisher = detector
//      .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
//      .dropFirst()
//      .eraseToAnyPublisher()
//    
//    self.detector = detector
//  }
//  
//  var body: some View {
//    let items = $viewModel.imageUrls.enumerated().map { $0 }
//    
//    ScrollView(.vertical) {
//      WaterfallGrid(items, id: \.element.id) { index, item in
//        ListImageRowItem(item: item, isLoading: .constant(true))
//      }
//      .gridStyle(columns: 2)
//      .scrollOptions(direction: .vertical)
//      .background(
//        GeometryReader {
//          Color.clear.preference(
//            key: ViewOffsetKey.self,
//            value: -$0.frame(in: .named("scroll")).origin.y
//          )
//        }
//      )
//      .onPreferenceChange(ViewOffsetKey.self) { detector.send($0) }
//    }
//    .coordinateSpace(.named("scroll"))
//    .onReceive(publisher) { coordinateY in
//      if coordinateY > 0 {
//        print("Stopped on: \(coordinateY)")
//        viewModel.requestMoreItemsIfNeeded()
//      }
//    }
//    .overlay {
//      if viewModel.dataIsLoading {
//        ProgressView()
//      }
//    }
//  }
//  
//}
//
//struct ViewOffsetKey: PreferenceKey {
//  typealias Value = CGFloat
//  static var defaultValue = CGFloat.zero
//  static func reduce(value: inout Value, nextValue: () -> Value) {
//    value += nextValue()
//  }
//}

//#Preview {
//  InfiniteListView()
//}









//struct GridItem: Identifiable {
//  
//  let id = UUID()
//  let height: CGFloat
//  let title: String
//  
//}
//
//
//struct InfiniteListView: View {
//  
//  struct Column: Identifiable {
//    
//    let id = UUID()
//    var gridItems = [GridItem]()
//    
//  }
//  
//  let columns: [Column]
//  
//  let spacing: CGFloat
//  let horizontalPadding: CGFloat
//  
//  @State private var image: [Image] = []
//  
//  @ObservedObject var viewModel: InfiniteListViewModel
//  
//  init(
//    viewModel: InfiniteListViewModel,
//    numberOfColumns: Int,
//    spacing: CGFloat = 20,
//    horizontalPadding: CGFloat = 20
//  ) {
//    self.spacing = spacing
//    self.horizontalPadding = horizontalPadding
//    
//    var columns = [Column]()
//    
//    for _ in 0 ..< numberOfColumns {
//      columns.append(Column())
//    }
//    
//    var columnsHeights = Array<CGFloat>(repeating: 0, count: numberOfColumns)
//    
//    for gridItem in gridItems {
//      var smallestColumnIndex = 0
//      var smallestHeight = columnsHeights.first!
//      
//      for i in 1 ..< columnsHeights.count {
//        let curHeight = columnsHeights[i]
//        
//        if curHeight < smallestHeight {
//          smallestHeight = curHeight
//          smallestColumnIndex = i
//        }
//      }
//      
//      columns[smallestColumnIndex].gridItems.append(gridItem)
//      columnsHeights[smallestColumnIndex] += gridItem.height
//    }
//    
//    self.columns = columns
//    
//    self.viewModel = viewModel
//    viewModel.requestInitialSetOfItems()
//  }
//  
//  var body: some View {
//    HStack(alignment: .top, spacing: spacing) {
//      ForEach(columns) { column in
//        LazyVStack(spacing: spacing) {
//          ForEach (column.gridItems) { gridItem in
//            Rectangle()
//              .foregroundStyle(.blue)
//              .frame(height: gridItem.height)
//              .overlay(
//                Text(gridItem.title)
//                  .font(.system(size: 30, weight: .bold))
//              )
//          }
//        }
//      }
//    }
//    .padding(.horizontal, horizontalPadding)
//  }
//  
//}
