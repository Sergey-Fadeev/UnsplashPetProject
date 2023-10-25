//
//  UnsplashPetProjectApp.swift
//  UnsplashPetProject
//
//  Created by Sergey on 09.10.2023.
//

import SwiftUI

@main
struct UnsplashPetProjectApp: App {
    var body: some Scene {
      WindowGroup {
        InfiniteListView2(viewModel: ImageLoaderViewModel())
        
//        ContentView(viewModel: ImageLoaderViewModel())
      }
    }
}




//@main
//struct UnsplashPetProjectApp: App {
//    var body: some Scene {
//      var gridItems = [GridItem]()
//      
//      for i in 0 ..< 30 {
//        let randomHeight = CGFloat.random(in: 100 ... 400)
//        gridItems.append(GridItem(height: randomHeight, title: "\(i)"))
//      }
//      
//      return WindowGroup {
//        ScrollView {
//          InfiniteListView(
//            viewModel: InfiniteListViewModel(),
//            gridItems: gridItems,
//            numberOfColumns: 2
//          )
//        }
//      }
//    }
//}
