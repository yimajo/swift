// RUN: %target-typecheck-verify-swift -swift-version 5 -module-name test -enable-experimental-feature TypedThrows

enum MyError: Error {
  case fail
}

enum MyBadError {
  case epicFail
}

// Thrown types must conform to Error
func testBadThrownError() throws(MyBadError) { }
// expected-error@-1{{thrown type 'MyBadError' does not conform to the 'Error' protocol}}

typealias BadThrowsMyError = () throws(MyBadError) -> Void
// expected-error@-1{{thrown type 'MyBadError' does not conform to the 'Error' protocol}}

func hasThrownMyError() throws(MyError) { }

typealias ThrowsMyError = () throws(MyError) -> Void

func testThrownMyErrorType() {
  let _: ThrowsMyError = hasThrownMyError
  let _: () -> Void = hasThrownMyError
  // expected-error@-1{{invalid conversion from throwing function of type '() throws(MyError) -> ()' to non-throwing function type '() -> Void'}}
}

func throwsGeneric<T: Error>(errorType: T.Type) throws(T) { }

func throwsBadGeneric<T>(errorType: T.Type) throws(T) { }
// expected-error@-1{{thrown type 'T' does not conform to the 'Error' protocol}}

func throwsUnusedInSignature<T: Error>() throws(T) { }
// expected-error@-1{{generic parameter 'T' is not used in function signature}}


func testSubstitutedType() {
  let _: (_: MyError.Type) -> Void = throwsGeneric
  // expected-error@-1{{invalid conversion from throwing function of type '(MyError.Type) throws(MyError) -> ()'}}
}
