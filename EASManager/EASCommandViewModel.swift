//
//  EASCommandViewModel.swift
//  EASManager
//
//  Created by Henry on 8/25/24.
//

import Foundation
import Combine

class EASCommandViewModel: ObservableObject {
    @Published var output: String = ""
    @Published var error: String?
    @Published var isLoading: Bool = false
    
    func runCommand(_ arguments: [String]) {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let result = CLIUtils.runEASCommand(arguments)
            
            DispatchQueue.main.async {
                self.output = result.output ?? ""
                self.error = result.error
                if self.error == nil && self.output.isEmpty {
                    self.error = "Command executed but produced no output. Please check if the EAS CLI path is correct."
                }
                self.isLoading = false
            }
        }
    }
}
