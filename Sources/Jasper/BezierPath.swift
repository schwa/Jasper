import CoreGraphics
import SwiftUI
import CoreGraphicsGeometrySupport

// swiftlint:disable force_unwrapping

public struct BezierCurve {
    public enum Order {
        case Quadratic
        case Cubic
        case OrderN(Int)
    }

    public var start: CGPoint?
    public var controls: [CGPoint]
    public var end: CGPoint

    public init(start: CGPoint? = nil, controls: [CGPoint], end: CGPoint) {
        self.start = start
        self.controls = controls
        self.end = end
    }

    public var order: Order {
        switch controls.count + 2 {
        case 3:
            return .Quadratic
        case 4:
            return .Cubic
        default:
            return .OrderN(controls.count + 2)
        }
    }
    public var points: [CGPoint] {
        if let start = start {
            return [start] + controls + [end]
        } else {
            return controls + [end]
        }
    }
}

// MARK: Convenience initializers

public extension BezierCurve {
//    init(control1: CGPoint, end: CGPoint) {
//        self.controls = [control1]
//        self.end = end
//    }
//
//    init(control1: CGPoint, control2: CGPoint, end: CGPoint) {
//        self.controls = [control1, control2]
//        self.end = end
//    }
//
//    init(start: CGPoint, control1: CGPoint, end: CGPoint) {
//        self.start = start
//        self.controls = [control1]
//        self.end = end
//    }
//
//    init(start: CGPoint, control1: CGPoint, control2: CGPoint, end: CGPoint) {
//        self.start = start
//        self.controls = [control1, control2]
//        self.end = end
//    }
//
//    init(points: [CGPoint]) {
//        self.start = points[0]
//        self.controls = Array(points[1..<points.count - 1])
//        self.end = points[points.count - 1]
//    }

    init(start: CGPoint, end: CGPoint) {
        self.start = start
        self.controls = [(start + end) / 2]
        self.end = end
    }
}

// MARK: Increasing the order.

public extension BezierCurve {
    func increasedOrder() -> BezierCurve {
        switch controls.count {
        case 1:
            let CP1 = points[0] + ((2.0 / 3.0) * (points[1] - points[0]))
            let CP2 = points[2] + ((2.0 / 3.0) * (points[1] - points[2]))
            return BezierCurve(start: start!, controls: [CP1, CP2], end: end)
        case 2:
            return self
        default:
            return BezierCurve(start: start!, end: end).increasedOrder()
        }
    }
}

// MARK: -

extension SwiftUI.Path {
    mutating func add(curve: BezierCurve) {
        switch curve.order {
        case .Quadratic:
            addQuadCurve(to: curve.end, control: curve.controls[0])
        case .Cubic:
            addCurve(to: curve.end, control1: curve.controls[0], control2: curve.controls[1])
        case .OrderN:
            fatalError("Unimplemented.")
        }
    }
}
