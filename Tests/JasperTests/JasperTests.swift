import XCTest
@testable import Jasper
@testable import JasperMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport

let testMacros: [String: Macro.Type] = [
    "KeyPaths": KeyPathsMacro.self,
]

final class MacroTests: XCTestCase {
    func testExample() throws {
        assertMacroExpansion(
            #"""
            @KeyPaths
            struct MyStruct {
                let member: Int
            }
            """#,
            expandedSource: #"""

            struct MyStruct {
                let member: Int
                public static let fields: [(String, PartialKeyPath<MyStruct>)] = [
                ("member", \MyStruct.member),
                ]
            }
            """#,
            macros: testMacros
        )
    }
    
}
