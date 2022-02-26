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

    func testFunction04() throws {
        let testParameters = ["int x", "boolean y"]
        let testFn =
        """
        class Main {
            function void testFunc(\(testParameters[0]), \(testParameters[1])) {
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
        XCTAssertEqual(fn.parameters[0].token.tokenType, .INT)
        XCTAssertEqual(fn.parameters[0].name.value, "x")
        XCTAssertEqual(fn.parameters[1].token.tokenType, .BOOLEAN)
        XCTAssertEqual(fn.parameters[1].name.value, "y")
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
        let args = ["2", "this"]
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
        XCTAssertEqual(doStmt.callExpression.arguments[0].selfTokenType, .INT_CONST)
        XCTAssertEqual(doStmt.callExpression.arguments[0].printSelf(), "2")
        XCTAssertEqual(doStmt.callExpression.arguments[1].selfTokenType, .THIS)
        XCTAssertEqual(doStmt.callExpression.arguments[1].printSelf(), "this")
    }

    func testIfStatement01() throws {
        let testCond = "false"
        let testIfStmt =
        """
        class Main {
            function void main() {
                if (\(testCond)) {
                } else {
                }
            }
        }
        """

        let lexer = Lexer(contentStr: testIfStmt)
        let parser = Parser(lexer: lexer)

        let program = parser.startParse()
        XCTAssertEqual(program.cls.functions[0].statements.count, 1)

        let stmt = program.cls.functions[0].statements[0]

        guard let ifStmt = stmt as? IfStatement else {
            XCTAssertThrowsError("Statement is not IF")
            return
        }

        XCTAssertEqual(ifStmt.token.tokenType, .IF)
        XCTAssertEqual(ifStmt.condition.printSelf(), testCond)
        XCTAssertEqual(ifStmt.alternative?.count, 0)
    }

    func testIfStatement02() throws {
        let testCond = "false"
        let testConseq = ["let a = 10;", "return a;"]
        let testIfStmt =
        """
        if (\(testCond)) {
            \(testConseq[0])
            \(testConseq[1])
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
    }

    func testIfStatement03() throws {
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

    func testIfStatement04() throws {
        let testCond = "true"
        let testConseqType = [TokenType.IF, TokenType.WHILE]
        let testConseq = [
            """
            \(testConseqType[0].rawValue) (true) {
                return 1;
            }
            """,
            """
            \(testConseqType[1].rawValue) (true) {
                return 1;
            }
            """]

        let testAlter = [
            """
            \(testConseqType[0].rawValue) (true) {
                return 0;
            }
            """,
            """
            \(testConseqType[1].rawValue) (true) {
                return 0;
            }
            """]

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
//

        let lexer = Lexer(contentStr: testIfStmt)
        let parser = Parser(lexer: lexer)

        let program = parser.startParse()
        XCTAssertEqual(program.cls.functions[0].statements.count, 1)

        let stmt = program.cls.functions[0].statements[0]
        print(stmt.printSelf())
        guard let ifStmt = stmt as? IfStatement else {
            XCTAssertThrowsError("Statement is not Do")
            return
        }

        XCTAssertEqual(ifStmt.token.tokenType, .IF)
        XCTAssertEqual(ifStmt.condition.printSelf(), testCond)
        for (index, conseq) in ifStmt.consequence.enumerated() {
            XCTAssertEqual(conseq.selfTokenType, testConseqType[index])
            XCTAssertEqual(conseq.printSelf(), testConseq[index])
        }
        for (index, alter) in ifStmt.alternative!.enumerated() {
            XCTAssertEqual(alter.selfTokenType, testConseqType[index])
            XCTAssertEqual(alter.printSelf(), testAlter[index])
        }
     }

    func testWhileStatement01() throws {
        let testCond = "true"
        let testConseqType = [TokenType.IF, TokenType.WHILE]
        let testConseq = [
            """
            \(testConseqType[0].rawValue) (true) {
                return 1;
            }
            """,
            """
            \(testConseqType[1].rawValue) (true) {
                return 1;
            }
            """]

        let testIfStmt =
        """
        while (\(testCond)) {
            \(testConseq[0])
            \(testConseq[1])
        }
        """

        let lexer = Lexer(contentStr: testIfStmt)
        let parser = Parser(lexer: lexer)

        let program = parser.startParse()
        XCTAssertEqual(program.cls.functions[0].statements.count, 1)

        let stmt = program.cls.functions[0].statements[0]
        guard let whileStmt = stmt as? WhileStatement else {
            XCTAssertThrowsError("Statement is not while")
            return
        }

        XCTAssertEqual(whileStmt.token.tokenType, TokenType.WHILE)
        XCTAssertEqual(whileStmt.condition.printSelf(), testCond)
        for (index, conseq) in whileStmt.consequence.enumerated() {
            XCTAssertEqual(conseq.selfTokenType, testConseqType[index])
            XCTAssertEqual(conseq.printSelf(), testConseq[index])
        }
    }

    func testInfixExpression01() throws {
        let testExp = "let infixTest = 1 + i;"

        let lexer = Lexer(contentStr: testExp)
        let parser = Parser(lexer: lexer)

        let program = parser.startParse()
        XCTAssertEqual(program.cls.functions[0].statements.count, 1)

        let stmt = program.cls.functions[0].statements[0]
        guard let letStmt = stmt as? LetStatement else {
            XCTAssertThrowsError("Statement is not let")
            return
        }

        guard let infixExp = letStmt.expression as? InfixExpression else {
            XCTAssertThrowsError("expression is not infixExpression")
            return
        }

        XCTAssertEqual(infixExp.left.selfTokenType, .INT_CONST)
        XCTAssertEqual(infixExp.operat.tokenType, .PLUS)
        XCTAssertEqual(infixExp.right.selfTokenType, .IDENTIFIER)
    }

    func testInfixExpression02() throws {
        let testExp = "let infixTest = ((y + size) < 254) & (510 > (x + size)));"

        let lexer = Lexer(contentStr: testExp)
        let parser = Parser(lexer: lexer)

        let program = parser.startParse()
        XCTAssertEqual(program.cls.functions[0].statements.count, 1)

        let stmt = program.cls.functions[0].statements[0]
        guard let letStmt = stmt as? LetStatement else {
            XCTAssertThrowsError("Statement is not let")
            return
        }

        guard let infixExp = letStmt.expression as? InfixExpression else {
            XCTAssertThrowsError("expression is not infixExpression")
            return
        }

        guard let leftExp = infixExp.left as? InfixExpression else {
            XCTAssertThrowsError("expression is not infixExpression")
            return
        }

        guard let leftFirstExp = leftExp.left as? InfixExpression else {
            XCTAssertThrowsError("expression is not infixExpression")
            return
        }

        guard let infixExp = letStmt.expression as? InfixExpression else {
            XCTAssertThrowsError("expression is not infixExpression")
            return
        }

        guard let rightExp = infixExp.right as? InfixExpression else {
            XCTAssertThrowsError("expression is not infixExpression")
            return
        }

        guard let rightSecondExp = rightExp.right as? InfixExpression else {
            XCTAssertThrowsError("expression is not infixExpression")
            return
        }

        XCTAssertEqual(leftFirstExp.left.selfTokenType, .IDENTIFIER)
        XCTAssertEqual(leftFirstExp.left.printSelf(), "y")
        XCTAssertEqual(leftFirstExp.operat.tokenType, .PLUS)
        XCTAssertEqual(leftFirstExp.right.selfTokenType, .IDENTIFIER)
        XCTAssertEqual(leftFirstExp.right.printSelf(), "size")

        XCTAssertEqual(leftExp.operat.tokenType, .LANGLE)
        XCTAssertEqual(leftExp.right.selfTokenType, .INT_CONST)
        XCTAssertEqual(leftExp.right.printSelf(), "254")

        XCTAssertEqual(infixExp.operat.tokenType, .AMPERSAND)

        XCTAssertEqual(rightExp.left.selfTokenType, .INT_CONST)
        XCTAssertEqual(rightExp.left.printSelf(), "510")

        XCTAssertEqual(rightExp.operat.tokenType, .RANGLE)

        XCTAssertEqual(rightSecondExp.left.selfTokenType, .IDENTIFIER)
        XCTAssertEqual(rightSecondExp.left.printSelf(), "x")
        XCTAssertEqual(rightSecondExp.operat.tokenType, .PLUS)
        XCTAssertEqual(rightSecondExp.right.selfTokenType, .IDENTIFIER)
        XCTAssertEqual(rightSecondExp.right.printSelf(), "size")
        print(infixExp.printSelf())
    }

    func testInfixExpression03() throws {
        let testExp = "let infixTest = (1 + 1) + 1;"
        let lexer = Lexer(contentStr: testExp)
        let parser = Parser(lexer: lexer)

        let program = parser.startParse()
        XCTAssertEqual(program.cls.functions[0].statements.count, 1)

        let stmt = program.cls.functions[0].statements[0]
        guard let letStmt = stmt as? LetStatement else {
            XCTAssertThrowsError("Statement is not let")
            return
        }

        guard let infixExp = letStmt.expression as? InfixExpression else {
            XCTAssertThrowsError("expression is not infixExpression")
            return
        }

        XCTAssertEqual(infixExp.printSelf(), "(1 + 1) + 1")
    }

    func testPrefixExpression01() throws {
        let testExp = "if(~(10 + size)) { return true; }"
        let lexer = Lexer(contentStr: testExp)
        let parser = Parser(lexer: lexer)

        let program = parser.startParse()
        XCTAssertEqual(program.cls.functions[0].statements.count, 1)

        let stmt = program.cls.functions[0].statements[0]
        guard let ifStmt = stmt as? IfStatement else {
            XCTAssertThrowsError("Statement is not if")
            return
        }

        guard let prefixExp = ifStmt.condition as? PrefixExpression else {
            XCTAssertThrowsError("expression is not prefixExpression")
            return
        }

        XCTAssertEqual(prefixExp.printSelf(), "~(10 + size)")
    }
}
