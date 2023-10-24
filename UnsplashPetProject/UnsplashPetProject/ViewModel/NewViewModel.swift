//
//  NewViewModel.swift
//  UnsplashPetProject
//
//  Created by Sergey on 24.10.2023.
//

import SwiftUI
import WaterfallGrid
import Combine

struct ContentView: View {
  @ObservedObject var viewModel: ImageLoaderViewModel
  
  //  var body: some View {
  //    VStack {
  //      if viewModel.images.isEmpty {
  //        // Если массив картинок пуст, показываем индикатор загрузки
  //        ProgressView()
  //      } else {
  //        // Иначе отображаем каждую загруженную картинку
  //        ScrollView {
  //          ForEach(viewModel.images, id: \.self) { image in
  //            Image(uiImage: image)
  //              .resizable()
  //              .aspectRatio(contentMode: .fit)
  //              .padding()
  //          }
  //        }
  //      }
  //    }
  //    .onAppear {
  //      // Запускаем загрузку картинок
  //      viewModel.requestItems(page: 1)
  //    }
  //  }
  
  
  
  
  let detector: CurrentValueSubject<CGFloat, Never>
  let publisher: AnyPublisher<CGFloat, Never>
  
  init(viewModel: ImageLoaderViewModel) {
    self.viewModel = viewModel
    viewModel.requestInitialSetOfItems()
    
    let detector = CurrentValueSubject<CGFloat, Never>(0)
    
    self.publisher = detector
      .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
      .dropFirst()
      .eraseToAnyPublisher()
    
    self.detector = detector
  }
  
  var body: some View {
    let items = $viewModel.domainImageList.enumerated().map { $0 }
    
    ScrollView(.vertical) {
      VStack {
        WaterfallGrid(items, id: \.element.id) { index, item in
          ListImageRowItem(item: item, isLoading: .constant(true))
        }
        .gridStyle(columns: 2)
        .scrollOptions(direction: .vertical)
        .background(
          GeometryReader {
            Color.clear.preference(
              key: ViewOffsetKey.self,
              value: -$0.frame(in: .named("scroll")).origin.y
            )
          }

        )
        .onPreferenceChange(ViewOffsetKey.self) { detector.send($0) }
      }
    }
    .coordinateSpace(.named("scroll"))
    .onReceive(publisher) { coordinateY in
      print("coordinateY - \(coordinateY)")
      
      if coordinateY > -100 {
        print("Stopped on: \(coordinateY)")
        viewModel.requestMoreItemsIfNeeded()
      }
    }
    .overlay {
      if viewModel.dataIsLoading {
        ProgressView()
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
  
  
  func requestInitialSetOfItems() {
    currentPage = 1
    requestItems(page: currentPage)
  }
  /// Used for infinite scrolling. Only requests more items if pagination criteria is met.
  func requestMoreItemsIfNeeded() {
    guard downloadingDataIsAvailable else {
      return
    }
    
    currentPage += 1
    requestItems(page: currentPage)
  }
  
  
  
  func requestItems(page: Int) {
    guard !dataIsLoading && canLoadMorePages else {
      return
    }
    
    downloadingDataIsAvailable = false
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
          
          self.downloadingDataIsAvailable = true
          
          self.imageUrlsSubject.send(response)
          
          print("imageUrls.count = \(imageUrls.count)")
        }
      )
      .store(in: &cancellables)
    
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
          
          print("сработал subject, images.count = \(images.count)")
          
          self.domainImageList += images
        }
      )
      .store(in: &cancellables)
  }
}









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
