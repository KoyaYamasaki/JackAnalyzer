//
//  TestLexer.swift
//  TestLexer
//
//  Created by 山崎宏哉 on 2022/02/06.
//  Copyright © 2022 山崎宏哉. All rights reserved.
//

import XCTest
@testable import TestBridgingTarget

class TestLexer: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test01() throws {
        let testStr =
        """
            // test


            class Main { // test2
                function void printHello() {
                    do Output.printString("Hello World");
                }
            }
        """

        let correctArray = [
            Token(tokenType: .CLASS, tokenLiteral: "class"),
            Token(tokenType: .IDENTIFIER, tokenLiteral: "Main"),
            Token(tokenType: .LBLACE, tokenLiteral: "{"),
            Token(tokenType: .FUNCTION, tokenLiteral: "function"),
            Token(tokenType: .VOID, tokenLiteral: "void"),
            Token(tokenType: .IDENTIFIER, tokenLiteral: "printHello"),
            Token(tokenType: .LPARENTHESIS, tokenLiteral: "("),
            Token(tokenType: .RPARENTHESIS, tokenLiteral: ")"),
            Token(tokenType: .LBLACE, tokenLiteral: "{"),
            Token(tokenType: .DO, tokenLiteral: "do"),
            Token(tokenType: .IDENTIFIER, tokenLiteral: "Output"),
            Token(tokenType: .DOT, tokenLiteral: "."),
            Token(tokenType: .IDENTIFIER, tokenLiteral: "printString"),
            Token(tokenType: .LPARENTHESIS, tokenLiteral: "("),
            Token(tokenType: .STRING_CONST, tokenLiteral: "\"Hello World\""),
            Token(tokenType: .RPARENTHESIS, tokenLiteral: ")"),
            Token(tokenType: .SEMICOLON, tokenLiteral: ";"),
            Token(tokenType: .RBLACE, tokenLiteral: "}"),
            Token(tokenType: .RBLACE, tokenLiteral: "}"),
        ]

        let testToken = Lexer(contentStr: testStr)

        var index = 0
        while testToken.hasMoreCommands() {
            let tok = testToken.advance()
            print("tokenType: ", tok.tokenType, "\nliteral: ", tok.tokenLiteral)
            print("==================")
            XCTAssertEqual(tok.tokenType, correctArray[index].tokenType)
            XCTAssertEqual(tok.tokenLiteral, correctArray[index].tokenLiteral)
            index += 1
        }
    }

}
