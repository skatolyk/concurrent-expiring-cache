//
//  ContentView.swift
//  concurrent-expiring-cache
//
//  Created by Severyn-Wsevolod on 03.04.2024.
//

import SwiftUI

final class ViewModel: ObservableObject {
    
    private let readQueue1 = DispatchQueue(label: "com.read.queue1", qos: .userInteractive, attributes: .concurrent)
    private let readQueue2 = DispatchQueue(label: "com.read.queue2", qos: .userInteractive, attributes: .concurrent)
    private let saveQueue1 = DispatchQueue(label: "com.save.queue1", qos: .userInteractive, attributes: .concurrent)
    private let saveQueue2 = DispatchQueue(label: "com.save.queue2", qos: .userInteractive, attributes: .concurrent)
    
    init() {
        print(CacheSystem.shared.getAll())
        CacheSystem.shared.save(data: "New Data", by: "key")
        
        test()
    }
    
    func test() {
        let key = "queue"
        
        saveQueue1.async {
            CacheSystem.shared.save(data: "readQueue", by: key)
            print("Save thread 1 save by key \(key)")
        }
        
        saveQueue2.async {
            CacheSystem.shared.remove(by: key)
            print("Save thread 2 remove: \(key)")
        }
        
        readQueue1.async {
            print("Read thread 1 read all: \(CacheSystem.shared.getAll())")
        }
        
        readQueue2.async {
            print("Read thread 2 read all: \(CacheSystem.shared.getAll())")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.test()
        }
    }
}

struct ContentView: View {
    
    let viewModel = ViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

// MARK: - Previews
#Preview {
    ContentView()
}
