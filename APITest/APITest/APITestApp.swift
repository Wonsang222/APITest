//
//  APITestApp.swift
//  APITest
//
//  Created by 황원상 on 4/21/24.
//

import SwiftUI

@main
struct APITestApp: App {
    
    @StateObject var todosVM: TodosVM = TodosVM()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Image(systemName:"1.square.fill")
                        Text("SwiftUI")
                    }
                MainVC.instantiate()
                    .getRepresentable()
                    .tabItem {
                        Image(systemName:"2.square.fill")
                        Text("UIKit")
                    }
            }
        }
    }
}
