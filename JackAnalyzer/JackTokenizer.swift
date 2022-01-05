//
//  JackTokenizer.swift
//  JackAnalyzer
//
//  Created by 山崎宏哉 on 2022/01/05.
//  Copyright © 2022 山崎宏哉. All rights reserved.
//

import Foundation

class JackTokenizer {

    private var commandByLine: [String] = []
    private var tokenList: [String] = []

    init(fileURL: URL) {

        guard let fileContents = try? String(contentsOf: fileURL) else {
            fatalError("File could not be read.")
        }

        commandByLine = fileContents.components(separatedBy: "\n")

        // Remove comment lines.
        commandByLine = commandByLine.filter {
            !$0.hasPrefix("//") && !$0.hasPrefix("/*")
        }

        // Remove Same line comment
        commandByLine = commandByLine.map({
            if let commentIndex = $0.range(of: "//") {
                return String($0[..<commentIndex.lowerBound])
            } else { return $0 }
        })

        // Remove spaces.
        commandByLine = commandByLine.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })

        // Remove line break lines.
        commandByLine = commandByLine.filter({ $0 != "\r" && !$0.isEmpty })

        for aOrder in commandByLine {
            let tokens = aOrder.components(separatedBy: " ")
            _ = tokens.map { tokenList.append($0) }
        }

        print(tokenList)
    }
}
