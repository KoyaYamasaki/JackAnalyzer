//
//  Extenstions.swift
//  JackAnalyzer
//
//  Created by 山崎宏哉 on 2022/01/06.
//  Copyright © 2022 山崎宏哉. All rights reserved.
//

import Foundation

extension Array where Element == String {
    mutating func shapeAndAppend(_ element: Element) {
        self.append(element.withIndent)
    }
}

extension String {
    var withIndent: String {
        self.indent(CompilationEngine.indentIndex)
    }

    func indent(_ index: Int) -> String {
        var strWithIndent = self
        for _ in 0..<index {
            strWithIndent.insert(" ", at: self.index(self.startIndex, offsetBy: 0))
        }

        return strWithIndent
    }
}

extension URL {
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
