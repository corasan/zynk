//
//  AppCommands.swift
//  Zynk
//
//  Created by Henry on 8/26/24.
//

import Foundation
import SwiftUI

struct AppCommands {    
    static func addProjectToRecent(_ projectPath: String) {
        var recentProjects = UserDefaults.standard.stringArray(forKey: "recentlyOpenedProjects") ?? []
        if !recentProjects.contains(projectPath) {
            recentProjects.insert(projectPath, at: 0)
            UserDefaults.standard.set(recentProjects, forKey: "recentlyOpenedProjects")
        }
    }
}
