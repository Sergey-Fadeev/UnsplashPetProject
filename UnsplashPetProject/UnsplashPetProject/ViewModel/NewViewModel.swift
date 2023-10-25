//
//  NewViewModel.swift
//  UnsplashPetProject
//
//  Created by Sergey on 24.10.2023.
//

import SwiftUI
import WaterfallGrid
import Combine

//struct ContentView: View {
//  @ObservedObject var viewModel: ImageLoaderViewModel
//  
//  //  var body: some View {
//  //    VStack {
//  //      if viewModel.images.isEmpty {
//  //        // Если массив картинок пуст, показываем индикатор загрузки
//  //        ProgressView()
//  //      } else {
//  //        // Иначе отображаем каждую загруженную картинку
//  //        ScrollView {
//  //          ForEach(viewModel.images, id: \.self) { image in
//  //            Image(uiImage: image)
//  //              .resizable()
//  //              .aspectRatio(contentMode: .fit)
//  //              .padding()
//  //          }
//  //        }
//  //      }
//  //    }
//  //    .onAppear {
//  //      // Запускаем загрузку картинок
//  //      viewModel.requestItems(page: 1)
//  //    }
//  //  }
//  
//  
//  
//  
//  let detector: CurrentValueSubject<CGFloat, Never>
//  let publisher: AnyPublisher<CGFloat, Never>
//  
//  init(viewModel: ImageLoaderViewModel) {
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
//    let items = $viewModel.domainImageList.enumerated().map { $0 }
//    
//    ScrollView(.vertical) {
//      VStack {
//        WaterfallGrid(items, id: \.element.id) { index, item in
//          ListImageRowItem(item: item, isLoading: .constant(true))
//        }
//        .gridStyle(columns: 2)
//        .scrollOptions(direction: .vertical)
//        .background(
//          GeometryReader {
//            Color.clear.preference(
//              key: ViewOffsetKey.self,
//              value: -$0.frame(in: .named("scroll")).origin.y
//            )
//          }
//
//        )
//        .onPreferenceChange(ViewOffsetKey.self) { detector.send($0) }
//      }
//    }
//    .coordinateSpace(.named("scroll"))
//    .onReceive(publisher) { coordinateY in
//      print("coordinateY - \(coordinateY)")
//      
//      if coordinateY > -100 {
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
//}

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
  
  
  @Published var columns: [Column] = [Column(), Column()]
  var leftHeight: Double = 0
  var rightHeight: Double = 0
  
  
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
          var leftHeights: Double = self.leftHeight
          var rightHeights: Double = self.rightHeight
          
//          for _ in 0 ..< 2 {
//            columns.append(Column())
//          }
          
          var columnsHeights = [leftHeights, rightHeights]
          
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
          
          
          
          
          
          
          
          
          
          
          
          
//          print("сработал subject, images.count = \(images.count)")
//          
//          self.domainImageList += images
        }
      )
      .store(in: &cancellables)
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


//
//
struct InfiniteListView2: View {
  
  struct Column: Identifiable {
    
    let id = UUID()
    var gridItems = [GridItem]()
    
  }
  
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
    .coordinateSpace(name: "scrollView")
    .onPreferenceChange(ViewOffsetKey.self) { minY in
      if minY > -50 {
        viewModel.requestMoreItemsIfNeeded()
      }
    }
  }
  
}

//NavigationView {
//  ScrollView {
//    LazyVStack {
//      ForEach(viewModel.images, id: \.self) { url in
//        AsyncImage(url: url)
//      }
//      
//      GeometryReader { geometry in
//        Color.clear.preference(key: ViewOffsetKey.self, value: geometry.frame(in: .named("scrollView")).minY)
//      }
//      .frame(height: 0)
//    }
//  }
//  .coordinateSpace(name: "scrollView")
//  .onPreferenceChange(ViewOffsetKey.self) { minY in
//    if minY > -50 {
//      viewModel.loadMoreImages()
//    }
//  }
//}
