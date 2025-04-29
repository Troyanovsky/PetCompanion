//
//  Logger.swift
//  PetCompanion
//
//  Created by Guodong Zhao on 4/29/25.
//

import Foundation

/// A simple logging utility for the PetCompanion app
class Logger {
    
    /// Log levels to categorize messages
    enum Level: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        
        var emoji: String {
            switch self {
            case .debug: return "🔍"
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            }
        }
    }
    
    /// Whether to include file and line information in logs
    static var includeSourceInfo = true
    
    /// Minimum log level to display (set to .debug for development, .info for production)
    #if DEBUG
    static var minimumLogLevel: Level = .debug
    #else
    static var minimumLogLevel: Level = .info
    #endif
    
    /// Log a message with the specified level
    /// - Parameters:
    ///   - level: The severity level of the log
    ///   - message: The message to log
    ///   - file: The file where the log was called from
    ///   - function: The function where the log was called from
    ///   - line: The line where the log was called from
    static func log(
        _ level: Level,
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        // Skip if below minimum log level
        guard level.rawValue >= minimumLogLevel.rawValue else { return }
        
        let timestamp = DateFormatter.localizedString(
            from: Date(),
            dateStyle: .none,
            timeStyle: .medium
        )
        
        var logMessage = "[\(timestamp)] \(level.emoji) [\(level.rawValue)] \(message)"
        
        if includeSourceInfo {
            let filename = URL(fileURLWithPath: file).lastPathComponent
            logMessage += " [\(filename):\(line) \(function)]"
        }
        
        // Print to console
        print(logMessage)
        
        // Here you could also add file logging if needed
        // appendToLogFile(logMessage)
    }
    
    // Convenience methods
    static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.debug, message, file: file, function: function, line: line)
    }
    
    static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.info, message, file: file, function: function, line: line)
    }
    
    static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.warning, message, file: file, function: function, line: line)
    }
    
    static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.error, message, file: file, function: function, line: line)
    }
    
    // Optional: Add file logging capability
    /*
    private static func appendToLogFile(_ message: String) {
        // Implementation for writing to log file
    }
    */
}