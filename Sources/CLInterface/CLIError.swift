//
//  CLIError.swift
//  commitPrefix
//
//  MIT License
//
//  Copyright (c) 2020 STEPHEN L. MARTINEZ
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
import Consler

public enum TerminationStatus: Int32 {
    /// Used when the app finishes as expected
    case successful
    
    /// Used when an error that has not been accounted for has been thrown
    case unexpectedError
    
    /// Used when the user takes an action that stops the application short
    case userInitiated
    
    /// Used when the inputs provided to the app are invalid
    case invalidInputs
    
    /// Used when the app can no longer continue due to user specified settings
    case invalidContext
    
    /// Used when required resources are inaccessible or unavailable
    case unavailableDependencies
    
    public var value: Int32 { self.rawValue }
}

public enum CLIError: Error, Equatable {

    case commandNotRecognized
    case tooManyArguments
    case emptyEntry
    case invalidEntryFormat
    case unexpectedError
    
    public var message: ConslerOutput {
        switch self {
        case .commandNotRecognized:
            return ConslerOutput(
                "Error: ", "Command not recognized. Enter ", "\"--help\"", " for usage.")
            .describedBy(.red(.bold), .normal, .cyan)
            
        case .tooManyArguments:
            return ConslerOutput(
                "Error: ", "Too many arguments entered. Only two at a time is supported.")
            .describedBy(.red(.bold))
            
        case .emptyEntry:
            return ConslerOutput("Error: ", "Your entry is empty.").describedBy(.red(.bold))
            
        case .invalidEntryFormat:
            return ConslerOutput("Error: ", "Your entry contains invalid spaces.")
                .describedBy(.red(.bold))
            
        case .unexpectedError:
            return ConslerOutput("Error: ", "An uncategorized error has occured")
                .describedBy(.red(.bold))
        }
    }
    
    public var status: TerminationStatus {
        switch self {
        case .commandNotRecognized:
            return .invalidInputs
        case .tooManyArguments:
            return .invalidInputs
        case .emptyEntry:
            return .invalidInputs
        case .invalidEntryFormat:
            return .invalidInputs
        case .unexpectedError:
            return .unexpectedError
        }
    }
    
}

extension Result where Failure == CLIError {
    
    func resolveOrExit() -> Success {
        switch self {
        case let .success(value):
            return value
        case let .failure(cliError):
            Consler.output(cliError.message, type: .error)
            exit(cliError.status.value)
        }
    }
    
}
