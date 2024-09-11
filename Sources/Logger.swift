import Foundation

func log(_ message: String) {
  var standardError = FileHandle.standardError
  print(message, to: &standardError)
}

extension FileHandle: @retroactive TextOutputStream {
  public func write(_ message: String) {
    write(message.data(using: .utf8)!)
  }
}
