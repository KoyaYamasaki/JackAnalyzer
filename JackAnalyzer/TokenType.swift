//
//  TokenType.swift
//  JackAnalyzer
//
//  Created by 山崎宏哉 on 2022/01/06.
//  Copyright © 2022 山崎宏哉. All rights reserved.
//

import Foundation

enum TokenType: String {
    case KEYWORD = "KEYWORD"
    case SYMBOL = "SYMBOL"
    case IDENTIFIER = "IDENTIFIER"
    case INT_CONST = "INT_CONST"
    case STRING_CONST = "STRING_CONST"
}
