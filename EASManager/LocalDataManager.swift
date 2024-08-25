//
//  LocalDataManager.swift
//  EASManager
//
//  Created by Henry on 8/25/24.
//

import Foundation

class LocalDataManager: ObservableObject {
    @Published var cliPath: String {
        didSet {
            UserDefaults.standard.set(cliPath, forKey: "EASCLIPath")
        }
    }
    
    init() {
        self.cliPath = UserDefaults.standard.string(forKey: "EASCLIPath") ?? ""
    }
}
