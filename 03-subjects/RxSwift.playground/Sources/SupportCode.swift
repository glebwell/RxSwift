import Foundation

public func example(of description: String, action: () -> Void) {
  print("\n--- Example of:", description, "---")
  action()
}

public func supportCode() {
    print("see supportCode.swift")
}
