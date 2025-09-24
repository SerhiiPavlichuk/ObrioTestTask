//
//  LogLevel.swift
//  ObrioTestTask
//
//  Created by Serhii on 24.09.2025.
//


import Foundation

enum LogLevel: String {
    case error = "❌ Error"
    case warning = "⚠️ Warning"
    case success = "✅ Success"
    case info = "ℹ️ Info"
    case debug = "🐞 Debug"
}

func logPrint(_ message: @autoclosure () -> Any,
         level: LogLevel = .debug,
         file: String = #file,
         function: String = #function,
         line: Int = #line) {
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    let logMessage = "\(level.rawValue) [\(fileName):\(line)] \(function):\n\t\(message())"
    print(logMessage)
    #endif
}
