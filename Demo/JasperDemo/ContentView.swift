import SwiftUI
import Jasper
import SwiftFormats
import CoreGraphicsGeometrySupport
import Everything

struct ContentView: View {
    @State
    private var operations: [Jasper.Operation] = [
        .draw(.stroke(shape: .rectangle(.init(origin: [0, 0], size: [1, 1])), color: .init(.black), style: .init())),
        .clip([.draw(.fill(shape: .rectangle(.init(origin: [0, 0], size: [1, 1])), color: .init(.black), style: .init())),])
    ]

    var body: some View {
        JasperStructureView(operations: $operations)
    }
}

public struct JasperStructureView: View {

    @Binding
    private var operations: [Jasper.Operation]

    @State
    var selectedOperationIndex: ListBox<Jasper.Operation>.ID?

    @State
    var listContent: [ListBox<Jasper.Operation>] = []

    @State
    var operationsById: [ListBox<Jasper.Operation>.ID:Jasper.Operation] = [:]


    public init(operations: Binding<[Jasper.Operation]>) {
        self._operations = operations
        self.selectedOperationIndex = selectedOperationIndex
    }

    public var body: some View {
        NavigationSplitView {
            List(listContent, children: \.children, selection: $selectedOperationIndex) { box in
                Text("\(String(describing: box.element))")
            }
            .toolbar {
                ControlGroup {
                    Button("Draw") {
                        let operation = Jasper.Operation.draw(.fill(shape: .rectangle(.init(origin: [0, 0], size: [1, 1])), color: .init(.black), style: .init()))
                        self.operations.append(operation)
                    }
                } label: {
                    Label("Plus", systemImage: "plus")
                }
                .controlGroupStyle(.compactMenu)
            }
        } detail: {
            ScrollView([.horizontal, .vertical]) {
                JasperView(operations: operations).frame(width: 6400, height: 4800)
            }
        }
        .inspector(isPresented: .constant(true)) {
            if let selectedOperationIndex {
                let operation = operation(at: selectedOperationIndex)
                Form {
                    inspector(for: operation, at: selectedOperationIndex)
                }
            }
        }
        .task {
            makeOperations()
        }
        .onChange(of: operations) {
            makeOperations()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            //            for index in offsets {
            //                shapes.delete(items[index])
            //            }
        }
    }


    nonisolated func makeOperations() {
        print(#function)
        var count = 0
        var operationsById: [ListBox<Jasper.Operation>.ID:Jasper.Operation] = [:]
        let listContent = zip(operations.indices, operations).map { ListBox(id: .init(index: $0.0), element: $0.1) { index, operation in
            count += 1
            operationsById[index] = operation
        } }
        print(count)
        //MainActor.runTask {
            self.operationsById = operationsById
            self.listContent = listContent
        //}
    }

    // Move to extension on Array<ListBox>
    func operation(at indexPath: IndexPath) -> Jasper.Operation {

        return operationsById[indexPath]!

//        assert(!indexPath.isEmpty)
//        var operation: Jasper.Operation!
//        var operations = operations
//        for index in indexPath {
//            operation = operations[index]
//            guard let children = operation.children else {
//                return operation
//            }
//            operations = children
//        }
//        return operation
    }

    @ViewBuilder
    func inspector(for operation: Jasper.Operation, at index: IndexPath) -> some View {
        Text(index.map({ $0.formatted() }).joined(separator: "."))
        switch operation {
        case .clip:
            Text("CLIP")
        case .layer:
            Text("LAYER")
        case .draw(let draw):
            switch draw {
            case .fill(shape: let shape, color: let color, style: let style):
                inspector(for: .constant(shape))
                Section("Color") {
                    KeyPathsEditor(subject: .constant(color))
                }
                Section("Fill Style") {
                    KeyPathsEditor(subject: .constant(style))
                }
            case .stroke(shape: let shape, color: let color, style: let style):
                inspector(for: .constant(shape))
                Section("Color") {
                    KeyPathsEditor(subject: .constant(color))
                }
                Section("Stroke Style") {
                    KeyPathsEditor(subject: .constant(style))
                }
            }
        case .transform:
            Text("TRANSFORM")
        case .text:
            Text("TEXT")
        }
    }

    @ViewBuilder
    func inspector(for shape: Binding<Jasper.Shape>) -> some View {
        let shape = shape.wrappedValue
        switch shape {
        case .ellipse(let shape):
            Section("Ellipse") {
                KeyPathsEditor(subject: .constant(shape))
            }
        case .rectangle(let shape):
            Section("Rectangle") {
                KeyPathsEditor(subject: .constant(shape))
            }
        case .lineSegment(let shape):
            Section("Line Segment") {
                KeyPathsEditor(subject: .constant(shape))
            }
        case .polygon(let shape):
            Section("Polygon") {
                KeyPathsEditor(subject: .constant(shape))
            }
        case .polyline(let shape):
            Section("Polyline") {
                KeyPathsEditor(subject: .constant(shape))
            }
        case .path(let shape):
            Section("Path") {
                KeyPathsEditor(subject: .constant(shape))
            }
        }
    }
}

#Preview {
    ContentView()
}

struct KeyPathsEditor <Subject>: View where Subject: KeyPathProviding {

    @Binding
    var subject: Subject

    var body: some View {
        ForEach(Array(zip(Subject.fields.indices, Subject.fields)), id: \.0) { (index, field) in
            let (name, keyPath) = field
            fieldEditor(name: name, keyPath: keyPath)
        }
    }

    @ViewBuilder
    func fieldEditor(name: String, keyPath: PartialKeyPath<Subject>) -> some View {
        switch keyPath {
        case let keyPath as WritableKeyPath<Subject, CGPoint>:
            let binding = Binding { subject[keyPath: keyPath] } set: { subject[keyPath: keyPath] = $0 }
            TextField(name, value: binding, format: .point)
        case let keyPath as WritableKeyPath<Subject, CGSize>:
            let binding = Binding { subject[keyPath: keyPath] } set: { subject[keyPath: keyPath] = $0 }
            TextField(name, value: binding, format: .size)
        case let keyPath as WritableKeyPath<Subject, Bool>:
            let binding = Binding { subject[keyPath: keyPath] } set: { subject[keyPath: keyPath] = $0 }
            Toggle(name, isOn: binding)
        case let keyPath as WritableKeyPath<Subject, CGColor>:
            let binding = Binding { subject[keyPath: keyPath] } set: { subject[keyPath: keyPath] = $0 }
            ColorPicker(selection: binding, supportsOpacity: true) {
                Text(name)
            }
        case let keyPath as WritableKeyPath<Subject, Float>:
            let binding = Binding { subject[keyPath: keyPath] } set: { subject[keyPath: keyPath] = $0 }
            TextField(name, value: binding, format: .number)
        case let keyPath as WritableKeyPath<Subject, Double>:
            let binding = Binding { subject[keyPath: keyPath] } set: { subject[keyPath: keyPath] = $0 }
            TextField(name, value: binding, format: .number)
        case let keyPath as WritableKeyPath<Subject, CGFloat>:
            let binding = Binding { Double(subject[keyPath: keyPath]) } set: { subject[keyPath: keyPath] = CGFloat($0) }
            TextField(name, value: binding, format: .number)
        default:
            LabeledContent(name, value: "<no editor for keyPath \(keyPath)>")
        }
    }

}

extension Jasper.Shape: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ellipse:
            return "ellipse"
        case .lineSegment:
            return "lineSegment"
        case .rectangle:
            return "rectangle"
        case .polygon:
            return "polygon"
        case .polyline:
            return "polyline"
        case .path:
            return "path"
        }
    }
}

extension Jasper.Operation: CustomStringConvertible {
    public var description: String {
        switch self {
        case .transform(_):
            return "transform"
        case .draw(_):
            return "draw"
        case .text(_):
            return "text"
        case .layer(_):
            return "layer"
        case .clip(_):
            return "clip"
        }
    }
}

struct ListBox <Element>: Identifiable {
    let id: IndexPath
    let element: Element
    var children: [ListBox <Element>]?
}

extension ListBox where Element == Jasper.Operation {

    init(id: IndexPath, element: Element, callback: (IndexPath, Element) -> Void) {
        self.id = id
        self.element = element
        callback(id, element)
        self.children = makeChildren(callback: callback)
    }

    func makeChildren(callback: (IndexPath, Element) -> Void) -> [Self]? {
        guard let children = element.children else {
            return nil
        }
        return zip(children.indices, children).map { ListBox(id: id.appending($0.0), element: $0.1, callback: callback) }
    }
}

extension Button {
    init(_ titleKey: LocalizedStringKey, systemImage: String, action: @escaping () -> Void) where Label == SwiftUI.Label<Text, Image> {
        self = Button(role: .none, action: action) {
            SwiftUI.Label(titleKey, systemImage: systemImage)
        }
    }
}

extension Jasper.Operation {
    var children: [Jasper.Operation]? {
        switch self {
        case .layer(let children):
            return children
        case .clip(let children):
            return children
        default:
            return nil
        }
    }
}

struct JasperView: View {
    let operations: [Jasper.Operation]

    var body: some View {
        Canvas { context, size in
            let start = CFAbsoluteTimeGetCurrent()
            context.draw(operations: operations)
            let end = CFAbsoluteTimeGetCurrent()
            print(end - start)
        }
    }
}

extension GraphicsContext {
    mutating func draw(operations: [Jasper.Operation]) {
        operations.forEach { operation in
            switch operation {
            case .transform(let transform):
                concatenate(transform)
            case .draw(let draw):
                switch draw {
                case .fill(shape: let shape, color: let color, style: let style):
                    let path = SwiftUI.Path(shape)
                    let color = SwiftUI.Color(color.cgColor)
                    let style = SwiftUI.FillStyle(style)
                    self.fill(path, with: .color(color), style: style)
                case .stroke(shape: let shape, color: let color, style: let style):
                    let path = SwiftUI.Path(shape)
                    let color = SwiftUI.Color(color.cgColor)
                    let style = SwiftUI.StrokeStyle(style)
                    self.stroke(path, with: .color(color), style: style)
                }
            case .layer(let operations):
                drawLayer { context in
                    context.draw(operations: operations)
                }
            default:
                break
            }
        }
    }
}

extension SwiftUI.Path {
    init(_ shape: Jasper.Shape) {
        switch shape {
        case .ellipse(let shape):
            self = Path(ellipseIn: CGRect(origin: shape.origin, size: shape.size))
        case .lineSegment(let shape):
            self = Path(lines: [(shape.from, shape.to)])
        case .rectangle(let shape):
            self = Path(CGRect(origin: shape.origin, size: shape.size))
        case .polygon(let shape):
            self = Path { path in
                path.addLines(shape.vertices)
                path.closeSubpath()
            }
        case .polyline(let shape):
            self = Path { path in
                path.addLines(shape.vertices)
            }
        case .path(let shape):
            self = Path(shape)
        }
    }
}

extension SwiftUI.FillStyle {
    init(_ style: Jasper.FillStyle) {
        self = .init(eoFill: style.isEOFilled, antialiased: style.isAntialiased)
    }
}

extension SwiftUI.StrokeStyle {
    init(_ style: Jasper.StrokeStyle) {
        self = .init(lineWidth: style.lineWidth, lineCap: .butt, lineJoin: .miter, miterLimit: style.miterLimit, dash: style.dash, dashPhase: style.dashPhase)
    }
}

extension SwiftUI.Path {
    init(_ path: Jasper.Path) {

        struct State {
            var currentPoint: CGPoint?
            var lastControlPoint: CGPoint?
        }

        let atoms = path.atoms

        self = Path{ path in
            var state = State()
            func convert(point: CGPoint, method: Positioning, update: Bool = true) -> CGPoint {
                let result: CGPoint
                switch method {
                case .absolute:
                    result = point
                case .relative:
                    if let currentPoint = state.currentPoint {
                        result = currentPoint + point
                    } else {
                        result = point
                    }
                }
                if update {
                    state.currentPoint = result
                }
                return result
            }

            for (index, command) in atoms.enumerated() {
                let currentPoint = state.currentPoint ?? CGPoint.zero

                switch command {
                case .moveto(let method, let points):
                    // M 100,100 200,100 200,200, 100,200, Z
                    // m 100,100 100,0 0,100 -100,0 z
                    guard let first = points.first else {
                        // TODO: We can't throw here so force to fatal error (least effort)
                        fatalError("Attempt to move without points in path")
                    }
                    let isFirst = index == 0
                    path.move(to: convert(point: first, method: isFirst ? .absolute : method))
                    for point in points.dropFirst() {
                        path.addLine(to: convert(point: point, method: method))
                    }
                case .closepath:
                    // Z
                    path.closeSubpath()
                case .lineto(let method, let points):
                    // M 100,100 L 200,100 200,200, 100,200, Z
                    // M 100,100 l 100,0 0,100 -100,0 z
                    for point in points {
                        path.addLine(to: convert(point: point, method: method))
                    }
                case .horizontalLineto(let method, let values):
                    // M 100, 100
                    for value in values {
                        path.addLine(to: convert(point: CGPoint(x: value, y: method == .absolute ? currentPoint.y : 0), method: method))
                    }
                case .verticalLineto(let method, let values):
                    for value in values {
                        path.addLine(to: convert(point: CGPoint(x: method == .absolute ? currentPoint.x : 0, y: value), method: method))
                    }
                case .curveto(let method, let points):
                    for subpoints in points.chunks(ofCount: 3) {
                        let subpoints = subpoints.extend(repeating: CGPoint.zero, to: 3)
                        let control1 = convert(point: subpoints[0], method: method, update: false)
                        let control2 = convert(point: subpoints[1], method: method, update: false)
                        let end = convert(point: subpoints[2], method: method, update: true)
                        let curve = BezierCurve(controls: [control1, control2], end: end)
                        path.add(curve: curve)
                        state.lastControlPoint = control2
                    }
                case .smoothCurveto(let method, let points):
                    for subpoints in points.chunks(ofCount: 2) {
                        let subpoints = subpoints.extend(repeating: CGPoint.zero, to: 2)
                        let lastControlPoint = state.lastControlPoint ?? currentPoint
                        let control1 = -1 * (lastControlPoint - currentPoint) + currentPoint
                        let control2 = convert(point: subpoints[0], method: method, update: false)
                        let end = convert(point: subpoints[1], method: method, update: true)
                        let curve = BezierCurve(controls: [control1, control2], end: end)
                        path.add(curve: curve)
                        state.lastControlPoint = control2
                    }
                case .quadraticBézierCurveto(let method, let points):
                    for subpoints in points.chunks(ofCount: 2) {
                        let subpoints = subpoints.extend(repeating: CGPoint.zero, to: 2)
                        let control1 = convert(point: subpoints[0], method: method, update: false)
                        let end = convert(point: subpoints[1], method: method, update: true)
                        let curve = BezierCurve(controls: [control1], end: end)
                        path.add(curve: curve)
                        state.lastControlPoint = control1
                    }
                case .smoothQuadraticBézierCurveto(let method, let points):
                    for point in points {
                        let control1 = -1 * ((state.lastControlPoint ?? currentPoint) - currentPoint) + currentPoint
                        let end = convert(point: point, method: method, update: true)
                        let curve = BezierCurve(controls: [control1], end: end)
                        path.add(curve: curve)
                        state.lastControlPoint = control1
                    }
                case .ellipticalArc(let method, let arc):
                    break
                    //                        let ellipticalArc = EllipticalArc(start: currentPoint, rx: arc.radii.x, ry: arc.radii.y, xAxisRotation: arc.xAxisRotation.radians, largeArcFlag: arc.largeArcFlag, sweepFlag: arc.sweepFlag, end: convert(point: arc.to, method: method, update: false))
                    //                        path.move(to: currentPoint)
                    //                        let curves = ellipticalArc.toBeziers(degree: 2, threshold: .leastNonzeroMagnitude)
                    //                        for curve in curves {
                    //                            path.add(curve: curve)
                    //                        }
                    //    //                    path.addLine(to: convert(point: arc.to, method: method, update: true))
                    //    //                    if arc.sweepFlag {
                    //    //                        path.closeSubpath()
                    //    //                    }
                    //                    }
                }
            }
            // #########################
        }
    }
}

extension Collection {
    func extend(repeating element: Element, to newCount: Int) -> Array<Element> {
        return Array(self) + Array(repeating: element, count: newCount - count)
    }
}
