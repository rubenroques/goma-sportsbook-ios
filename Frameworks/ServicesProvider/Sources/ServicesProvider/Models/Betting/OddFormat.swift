
public enum OddFormat: Codable, Equatable, Hashable {
    case fraction(numerator: Int, denominator: Int)
    case decimal(odd: Double)

    public var fractionOdd: (numerator: Int, denominator: Int)? {
        switch self {
        case .fraction(let numerator, let denominator):
            return (numerator: numerator, denominator: denominator)
        case .decimal:
            return nil
        }
    }

    public var decimalOdd: Double {
        switch self {
        case .fraction(let numerator, let denominator):
            let decimal = (Double(numerator)/Double(denominator)) + 1.0
            if decimal.isNaN {
                return decimal
            }
            else {
                return decimal
            }
        case .decimal(let odd):
            return odd
        }
    }
}
