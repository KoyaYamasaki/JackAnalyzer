//
//  TestParser.swift
//  TestParser
//
//  Created by 山崎宏哉 on 2022/02/09.
//  Copyright © 2022 山崎宏哉. All rights reserved.
//

import XCTest
@testable import TestBridgingTarget

class TestParser: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testClass01() throws {
        let testClsName = "TestCls"
        let testVars = ["static boolean test;", "field int xxx;"]
        let testCls =
        """
        class \(testClsName) {
            \(testVars[0])
            \(testVars[1])
            function void main() {
                return 0;
            }
        }
        """

        let lexer = Lexer(contentStr: testCls)
        let parser = Parser(lexer: lexer)
        let program = parser.startParse()
        let cls = program.cls
        print("class:\n", cls.printSelf())
        XCTAssertEqual(cls.printSelf(), testCls)
        XCTAssertEqual(cls.token.tokenType, .CLASS)
        XCTAssertEqual(cls.name.token.tokenType, .IDENTIFIER)
        XCTAssertEqual(cls.name.value, testClsName)
        XCTAssertEqual(cls.vars[0].token.tokenType, .STATIC)
        XCTAssertEqual(cls.vars[1].token.tokenType, .FIELD)
        XCTAssertEqual(cls.vars[0].type.tokenType, .BOOLEAN)
        XCTAssertEqual(cls.vars[1].type.tokenType, .INT)
        XCTAssertEqual(cls.vars[0].names[0].value, "test")
        XCTAssertEqual(cls.vars[1].names[0].value, "xxx")
    }

    func testClass02() throws {
        let testCls = "let testNoCls = 10;"
        let expectClsStr =
        """
        class Main {
            function void main() {
                \(testCls)
            }
        }
        """

        let lexer = Lexer(contentStr: testCls)
        let parser = Parser(lexer: lexer)
        let program = parser.startParse()
        let cls = program.cls

        XCTAssertEqual(cls.printSelf(), expectClsStr)
        XCTAssertEqual(cls.token.tokenType, .CLASS)
        XCTAssertEqual(cls.name.token.tokenType, .IDENTIFIER)
        XCTAssertEqual(cls.name.value, "Main")
    }
    
    func testClass03() throws {
        let testFnName = ["main", "more"]
        let testVarsType = ["SquareGame", "boolean"]
        let testVarsName = ["game", "b"]
        let testCls =
        """
        class Main {
            function void \(testFnName[0])() {
                var \(testVarsType[0]) \(testVarsName[0]);
                let game = game;
                do game.run();
                do game.dispose();
                return;
            }
            function void \(testFnName[1])() {
                var \(testVarsType[1]) \(testVarsName[1]);
                if (b) {
                }
                else {
                }
                return;
            }
        }
        """

        let lexer = Lexer(contentStr: testCls)
        let parser = Parser(lexer: lexer)
        let program = parser.startParse()
        let cls = program.cls

        XCTAssertEqual(cls.token.tokenType, .CLASS)
        XCTAssertEqual(cls.name.token.tokenType, .IDENTIFIER)
        XCTAssertEqual(cls.name.value, "Main")
        for (index, fn) in cls.functions.enumerated() {
            XCTAssertEqual(fn.name.value, testFnName[index])
            XCTAssertEqual(fn.vars[0].token.tokenType, .VAR)
            XCTAssertEqual(fn.vars[0].type.tokenLiteral, testVarsType[index])
            XCTAssertEqual(fn.vars[0].names[0].value, testVarsName[index])
        }
    }

    func testFunction01() throws {
        let testFnName = "testFn"
        let returnType = Token(tokenType: .VOID, tokenLiteral: "void")
        let testFn =
            """
            class Main {
                function void \(testFnName)() {
                    return 0;
                }
            }
            """

        let lexer = Lexer(contentStr: testFn)
        let parser = Parser(lexer: lexer)
        let program = parser.startParse()
        XCTAssertEqual(program.cls.functions.count, 1)

        let fn = program.cls.functions[0]

        XCTAssertEqual(fn.token.tokenType, .FUNCTION)
        XCTAssertEqual(fn.returnType.tokenType, returnType.tokenType)
        XCTAssertEqual(fn.name.value, testFnName)
    }

    func testFunction02() throws {
        let testfn = "return true;"
        let expectFn =
            """
            function void main() {
                \(testfn)
            }
            """

        let lexer = Lexer(contentStr: testfn)
        let parser = Parser(lexer: lexer)
        let program = parser.startParse()
        XCTAssertEqual(program.cls.functions.count, 1)

        let fn = program.cls.functions[0]

        XCTAssertEqual(fn.printSelf(), expectFn)
        XCTAssertEqual(fn.token.tokenType, .FUNCTION)
        XCTAssertEqual(fn.returnType.tokenType, .VOID)
        XCTAssertEqual(fn.name.value, "main")
    }

    func testFunction03() throws {
        let testVars = ["var int x;", "var XClass isDigit;", "var int y, z;"]
        let testFn =
        """
        class Main {
            function void testFunc() {
                \(testVars[0])
                \(testVars[1])
                \(testVars[2])
                return x;
            }
        }
        """

        let lexer = Lexer(contentStr: testFn)
        let parser = Parser(lexer: lexer)
        let program = parser.startParse()
        XCTAssertEqual(program.cls.functions.count, 1)

        let fn = program.cls.functions[0]

        XCTAssertEqual(fn.token.tokenType, .FUNCTION)
        XCTAssertEqual(fn.returnType.tokenType, .VOID)
        XCTAssertEqual(fn.name.value, "testFunc")
    }

    func testLetStatement() throws {
        let testCount = 3
        let testIdent = ["letIdentifier", "x", "y"]
        let testExpression = ["true", "15", "x"]

        for i in 0..<testCount {
            let testStmt = "let \(testIdent[i]) = \(testExpression[i]);"

            let lexer = Lexer(contentStr: testStmt)
            let parser = Parser(lexer: lexer)

            let program = parser.startParse()
            XCTAssertEqual(program.cls.functions[0].statements.count, 1)

            let stmt = program.cls.functions[0].statements[0]

            guard let letStmt = stmt as? LetStatement else {
                XCTAssertThrowsError("Statement is not LET")
                return
            }

            XCTAssertEqual(letStmt.printSelf(), testStmt)
            XCTAssertEqual(letStmt.name.token.tokenType, .IDENTIFIER)
            XCTAssertEqual(letStmt.name.value, testIdent[i])

            XCTAssertEqual(letStmt.expression.printSelf(), testExpression[i])
        }
    }

    func testReturnStatement() throws {
        let testCount = 4
        let testExpression = ["true", "5", "foobar", ""]


        for i in 0..<testCount {
            var testStmt = ""
            testStmt = testExpression[i] != "" ? "return \(testExpression[i]);" : "return;"

            let lexer = Lexer(contentStr: testStmt)
            let parser = Parser(lexer: lexer)
            
            let program = parser.startParse()
            XCTAssertEqual(program.cls.functions[0].statements.count, 1)
            
            let stmt = program.cls.functions[0].statements[0]
            
            guard let returnStmt = stmt as? ReturnStatement else {
                XCTAssertThrowsError("Statement is not Return")
                return
            }

            XCTAssertEqual(returnStmt.printSelf(), testStmt)

            XCTAssertEqual(returnStmt.token.tokenType, .RETURN)
            if let exp = returnStmt.expression {
                XCTAssertEqual(exp.printSelf(), testExpression[i])
            }
        }
    }

    func testDoStatement() throws {
        let fnName = "add"
        let args = ["2", "3"]
        let testStmt = "do \(fnName)(\(args[0]), \(args[1]));"

        let lexer = Lexer(contentStr: testStmt)
        let parser = Parser(lexer: lexer)

        let program = parser.startParse()
        XCTAssertEqual(program.cls.functions[0].statements.count, 1)

        let stmt = program.cls.functions[0].statements[0]

        guard let doStmt = stmt as? DoStatement else {
            XCTAssertThrowsError("Statement is not Do")
            return
        }

        XCTAssertEqual(doStmt.printSelf(), testStmt)

        XCTAssertEqual(doStmt.token.tokenType, .DO)
        XCTAssertEqual(doStmt.callExpression.fnName.token.tokenType, .IDENTIFIER)
        XCTAssertEqual(doStmt.callExpression.fnName.value, fnName)
        for (index, arg) in doStmt.callExpression.arguments.enumerated() {
            XCTAssertEqual(arg.printSelf(), args[index])
        }
    }

    func testIfStatement01() throws {
        let testCond = "false"
        let testIfStmt =
        """
        if (\(testCond)) {
        } else {
        }
        """

        let lexer = Lexer(contentStr: testIfStmt)
        let parser = Parser(lexer: lexer)

        let program = parser.startParse()
        XCTAssertEqual(program.cls.functions[0].statements.count, 1)

        let stmt = program.cls.functions[0].statements[0]

        guard let ifStmt = stmt as? IfStatement else {
            XCTAssertThrowsError("Statement is not Do")
            return
        }

        XCTAssertEqual(ifStmt.token.tokenType, .IF)
        XCTAssertEqual(ifStmt.condition.printSelf(), testCond)
    }

    func testIfStatement02() throws {
        let testCond = "true"
        let testConseq = ["let a = 10;", "return a;"]
        let testAlter = ["let b = true;", "return b;"]
        let testIfStmt =
        """
        if (\(testCond)) {
            \(testConseq[0])
            \(testConseq[1])
        } else {
            \(testAlter[0])
            \(testAlter[1])
        }
        """

        let lexer = Lexer(contentStr: testIfStmt)
        let parser = Parser(lexer: lexer)

        let program = parser.startParse()
        XCTAssertEqual(program.cls.functions[0].statements.count, 1)

        let stmt = program.cls.functions[0].statements[0]

        guard let ifStmt = stmt as? IfStatement else {
            XCTAssertThrowsError("Statement is not Do")
            return
        }

        XCTAssertEqual(ifStmt.token.tokenType, .IF)
        XCTAssertEqual(ifStmt.condition.printSelf(), testCond)
        for (index, conseq) in ifStmt.consequence.enumerated() {
            XCTAssertEqual(conseq.printSelf(), testConseq[index])
        }
        for (index, alter) in ifStmt.alternative!.enumerated() {
            XCTAssertEqual(alter.printSelf(), testAlter[index])
        }
     }
}
