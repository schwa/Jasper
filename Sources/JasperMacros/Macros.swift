import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

@main
struct MetalSupportMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        KeyPathsMacro.self,
    ]
}

// MARK: -

public struct KeyPathsMacro {

}

extension KeyPathsMacro: ConformanceMacro {
    public static func expansion<Declaration, Context>(of node: SwiftSyntax.AttributeSyntax, providingConformancesOf declaration: Declaration, in context: Context) throws -> [(SwiftSyntax.TypeSyntax, SwiftSyntax.GenericWhereClauseSyntax?)] where Declaration : SwiftSyntax.DeclGroupSyntax, Context : SwiftSyntaxMacros.MacroExpansionContext {
        return [("KeyPathProviding", nil)]
    }
    
}


extension KeyPathsMacro: MemberMacro {
    public static func expansion<Declaration, Context>(of node: AttributeSyntax, providingMembersOf declaration: Declaration, in context: Context) throws -> [DeclSyntax] where Declaration : DeclGroupSyntax, Context : MacroExpansionContext {
        let parentName: String
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            parentName = structDecl.identifier.trimmedDescription
        }
        else {
            fatalError()
        }
        let keyPaths = declaration.memberBlock.members.compactMap { member -> DeclSyntax? in
            guard let variableDecl = member.decl.as(VariableDeclSyntax.self) else {
                return nil
            }
            //let pattern = variableDecl.bindings.first?.pattern
            guard let variableName = variableDecl.bindings.first?.pattern.trimmedDescription else {
                return nil // throw
            }
            return "(\"\(raw: variableName)\", \\\(raw: parentName).\(raw: variableName)),"
        }

        return [
            """
            public static let fields: [(String, PartialKeyPath<\(raw: parentName)>)] = [
            """
            ]
            + keyPaths +
            [
            """
            ]
            """

        ]
    }
    

}

