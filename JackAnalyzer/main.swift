//
//  main.swift
//  JackAnalyzer
//
//  Created by 山崎宏哉 on 2022/01/05.
//  Copyright © 2022 山崎宏哉. All rights reserved.
//

import Foundation

class Main {
    static let analyzer = JackAnalyzer()
    static func main() {
        let arguments = ProcessInfo().arguments
        let currentPath = FileManager.default.currentDirectoryPath
        
        guard arguments.count > 1 else {
            fatalError("target .vm file is not specified.")
        }

        let url = URL(fileURLWithPath: arguments[1])
        if !url.isDirectory {
            analyzer.compileSingleFile(url)
        } else {
            analyzer.compileMultiFiles(url)
        }
    }
}

Main.main()
