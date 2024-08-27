//
//  Profile.swift
//  EASManager
//
//  Created by Henry on 8/24/24.
//

import Foundation

enum DistributionType: String, CustomStringConvertible {
    case `internal` = "internal"
    case store = "store"
    
    var description: String {
        switch self {
        case .internal:
            return "Internal"
        case .store:
            return "Store"
        }
    }
    
    init?(rawValue: String) {
        switch rawValue.lowercased() {
        case "internal":
            self = .internal
        case "store":
            self = .store
        default:
            return nil
        }
    }
}

struct Profile: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let developmentClient: Bool
    let channel: String
    let distribution: DistributionType
}
