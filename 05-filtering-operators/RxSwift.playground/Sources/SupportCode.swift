import Foundation

public func example(of description: String, action: () -> Void) {
  print("\n--- Example of:", description, "---")
  action()
}

public func supportCode() {
    print("see supportCode.swift")
}

public func phoneNumber(from inputs: [Int]) -> String {
  var phone = inputs.map(String.init).joined()

  phone.insert("-", at: phone.index(
    phone.startIndex,
    offsetBy: 3)
  )

  phone.insert("-", at: phone.index(
    phone.startIndex,
    offsetBy: 7)
  )

  return phone
}
