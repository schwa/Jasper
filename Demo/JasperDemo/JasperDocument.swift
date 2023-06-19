import SwiftUI
import UniformTypeIdentifiers
import Jasper

struct JasperDocument: FileDocument {
    static var readableContentTypes: [UTType] = [.json]

    var operation: Jasper.Operation

    init(configuration: ReadConfiguration) throws {


        guard let data = configuration.file.regularFileContents else {
            fatalError()
        }

        operation = try JSONDecoder().decode(Jasper.Operation.self, from: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        fatalError()
    }
    

}
