//
//  CacheApp.swift
//  concurrent-expiring-cache
//
//  Created by Severyn-Wsevolod on 03.04.2024.
//

import SwiftUI

@main
struct CacheApp: App {
    init() {
        CacheSystem.shared.loadData()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
