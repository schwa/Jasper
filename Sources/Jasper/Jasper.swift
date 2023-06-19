import CoreGraphics
import CoreGraphicsGeometrySupport
import Foundation
import struct SwiftUI.Angle

public protocol ShapeProtocol: Codable, Equatable {
}

@KeyPaths
public struct Arc: ShapeProtocol {
    public var radii: CGPoint
    public var xAxisRotation: SwiftUI.Angle
    public var largeArcFlag: Bool
    public var sweepFlag: Bool
    public var to: CGPoint

    public init(radii: CGPoint, xAxisRotation: Angle, largeArcFlag: Bool, sweepFlag: Bool, to: CGPoint) {
        self.radii = radii
        self.xAxisRotation = xAxisRotation
        self.largeArcFlag = largeArcFlag
        self.sweepFlag = sweepFlag
        self.to = to
    }

    public init(from decoder: Decoder) throws {
        fatalError()
    }

    public func encode(to encoder: Encoder) throws {
        fatalError()
    }
}

@KeyPaths
public struct Polygon: ShapeProtocol {
    public var vertices: [CGPoint]

    public init(vertices: [CGPoint]) {
        self.vertices = vertices
    }
}

@KeyPaths
public struct Polyline: ShapeProtocol {
    public var vertices: [CGPoint]

    public init(vertices: [CGPoint]) {
        self.vertices = vertices
    }
}

@KeyPaths
public struct Ellipse: ShapeProtocol {
    public var center: CGPoint
    public var size: CGSize
    
    public init(center: CGPoint, radius: CGFloat) {
        self.center = center
        self.size = CGSize(width: radius * 2, height: radius * 2)
    }

    public init(center: CGPoint, radii: CGSize) {
        self.center = center
        self.size = CGSize(width: radii.width * 2, height: radii.height * 2)
    }

    public var origin: CGPoint {
        return center - CGPoint(size) * 0.5
    }
}

@KeyPaths
public struct LineSegment: ShapeProtocol {
    public var from: CGPoint
    public var to: CGPoint

    public init(from: CGPoint, to: CGPoint) {
        self.from = from
        self.to = to
    }
}

@KeyPaths
public struct Rectangle: ShapeProtocol {
    public var origin: CGPoint
    public var size: CGSize

    public init(origin: CGPoint, size: CGSize) {
        self.origin = origin
        self.size = size
    }
}

public enum Positioning: Codable, Equatable {
    case absolute
    case relative
}

@KeyPaths
public struct Path: ShapeProtocol {
    public enum Atom: Codable, Equatable {
        case moveto(Positioning, [CGPoint])
        case closepath
        case lineto(Positioning, [CGPoint])
        case horizontalLineto(Positioning, [CGFloat])
        case verticalLineto(Positioning, [CGFloat])
        case curveto(Positioning, [CGPoint])
        case smoothCurveto(Positioning, [CGPoint])
        case quadraticBézierCurveto(Positioning, [CGPoint])
        case smoothQuadraticBézierCurveto(Positioning, [CGPoint])
        case ellipticalArc(Positioning, Arc)
    }
    public var atoms: [Atom]

    public init(atoms: [Atom]) {
        self.atoms = atoms
    }
}

@KeyPaths
public struct FillStyle: Equatable, Codable {
    public var isEOFilled: Bool
    public var isAntialiased: Bool

    public init(isEOFilled: Bool = true, isAntialiased: Bool = true) {
        self.isEOFilled = isEOFilled
        self.isAntialiased = isAntialiased
    }

}

public enum Shape: Equatable, Codable {
    case ellipse(Ellipse)
    case lineSegment(LineSegment)
    case rectangle(Rectangle)
    case polygon(Polygon)
    case polyline(Polyline)
    case path(Path)
}

@KeyPaths
public struct Color: Equatable, Codable {
    public var cgColor: CGColor

    public init(_ cgColor: CGColor) {
        self.cgColor = cgColor
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.singleValueContainer()
        let components = try container.decode([CGFloat].self)
        switch components.count {
        case 2:
            cgColor = CGColor(gray: components[0], alpha: components[1])
        case 4:
            cgColor = CGColor(red: components[0], green: components[1], blue: components[2], alpha: components[3])
        default:
            fatalError()
        }
    }

    public func encode(to encoder: Encoder) throws {
        guard let components = cgColor.components else {
            fatalError()
        }
        var container = encoder.singleValueContainer()
        try container.encode(components)
    }
}

@KeyPaths
public struct StrokeStyle: Equatable, Codable {
    public var lineWidth: CGFloat
    public var lineCap: LineCap
    public var lineJoin: LineJoin
    public var miterLimit: CGFloat
    public var dash: [CGFloat]
    public var dashPhase: CGFloat

    public enum LineCap: Codable {
        case butt
        case round
        case square
    }

    public enum LineJoin: Codable {
        case miter
        case round
        case bevel
    }

    public init(lineWidth: CGFloat = 1.0, lineCap: LineCap = .butt, lineJoin: LineJoin = .miter, miterLimit: CGFloat = 0, dash: [CGFloat] = [], dashPhase: CGFloat = 0) {
        self.lineWidth = lineWidth
        self.lineCap = lineCap
        self.lineJoin = lineJoin
        self.miterLimit = miterLimit
        self.dash = dash
        self.dashPhase = dashPhase
    }
}

public enum Draw: Equatable, Codable {
    case fill(shape: Shape, color: Color, style: FillStyle)
    case stroke(shape: Shape, color: Color, style: StrokeStyle)
}

public enum Operation: Equatable, Codable {
    case transform(CGAffineTransform)
    case draw(Draw)
    case text(AttributedString) // TODO
    case layer([Operation])
    case clip([Operation])
}
