//
//  CacheSystem.swift
//  concurrent-expiring-cache
//
//  Created by Severyn-Wsevolod on 03.04.2024.
//

import Foundation

//struct AnyItem: Codable { // Type erasure struct
//    let data: Codable
//    
//    init<T: Codable>(_ data: T) {
//        self.data = data
//    }
//}

struct CacheData: Codable {
    let expirationTimeStamp: TimeInterval
    let data: String
    
    var isExpired: Bool {
        let expirationDate = Date(timeIntervalSince1970: expirationTimeStamp)
        return expirationDate < Date.now
    }
    
    init(data: String) {
        self.expirationTimeStamp = Date.now.timeIntervalSince1970 + 60
        self.data = data
    }
}

final class CacheSystem {
    
    static let shared = CacheSystem() // TODO: @skatolyk - Implement DI
    private init() { 
        startCheckExpirations()
    }
    
    private let queue = DispatchQueue(label: "com.cache.system.queue", qos: .background, attributes: .concurrent)
    
    var fileURL: URL = {
        let folderURL = try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        
        return folderURL.appendingPathComponent("expiring_cache")
    }()
    
    private var inmemoryData: [String: CacheData] = [:]
    
    func loadData() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            do {
                let data = try Data(contentsOf: self.fileURL)
                self.inmemoryData = try JSONDecoder().decode([String: CacheData].self, from: data)
            } catch {
                // TODO: @skatolyk - handle error
                print(error.localizedDescription)
            }
        }
    }
    
    func save(data: String, by key: String) {
        queue.async(flags: .barrier) { [weak self, fileURL] in
            guard let self = self else { return }
            
            self.inmemoryData[key] = CacheData(data: data)
            do {
                let dataToSave = try JSONEncoder().encode(self.inmemoryData)
                try dataToSave.write(to: fileURL)
            } catch {
                // TODO: @skatolyk - handle error
                print(error.localizedDescription)
            }
        }
    }
    
    func remove(by key: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            guard let removedValue = self.inmemoryData.removeValue(forKey: key) else {
                return print("Cant remove value by key: \(key)")
            }
            print("Removed: \(removedValue)")
            self.resaveData()
        }
    }
    
    func get(by key: String) -> CacheData? {
        queue.sync {
            inmemoryData[key].flatMap {
                return $0.isExpired ? nil : $0
            }
        }
    }
    
    func getAll() -> [String: CacheData] {
        queue.sync { inmemoryData }
    }
    
    func checkExpirations() {
        if inmemoryData.isEmpty { return }
        
        print("Start cleaning!")
        
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            let primaryCount = self.inmemoryData.count
            
            self.inmemoryData.removeIf {
                if $0.value.isExpired {
                    print("Remove: \($0.value)")
                    return true
                } else {
                    print("Still actual: \($0.value)")
                    return false
                }
            }
            
            if primaryCount > self.inmemoryData.count {
                self.resaveData()
            } else {
                print("Nothing to update")
            }
        }
    }
}

// MARK: - Privates
private extension CacheSystem {
    private func startCheckExpirations() {
        checkExpirations()

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.startCheckExpirations()
        }
    }
    
    func resaveData() {
        print("Resave Data")
        do {
            let dataToSave = try JSONEncoder().encode(self.inmemoryData)
            try dataToSave.write(to: fileURL)
        } catch {
            // TODO: @skatolyk - handle error
            print(error.localizedDescription)
        }
    }
}
