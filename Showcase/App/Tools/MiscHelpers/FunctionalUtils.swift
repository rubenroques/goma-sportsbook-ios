import Foundation

typealias ResultCallback<T> = (Result<T, Error>) -> Void

precedencegroup ForwardApplication {
  associativity: left
}

infix operator |>: ForwardApplication

func |> <A, B>(x: A, f: (A) -> B) -> B {  // swiftlint:disable:this identifier_name
  return f(x)
}

precedencegroup ForwardComposition {
  higherThan: ForwardApplication
  associativity: right
}
infix operator >>>: ForwardComposition

// swiftlint:disable identifier_name
func >>> <A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> ((A) -> C) {
  return { a in g(f(a)) }
}
// swiftlint:enable identifier_name
