//
//  CPError.swift
//  commitPrefix
//
//  MIT License
//
//  Copyright (c) 2019 STEPHEN L. MARTINEZ
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

import Consler
import Foundation

enum TerminationStatus: Int32 {
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
    
    var value: Int32 { self.rawValue }
}

enum CPError: Error {
    
    // MARK: - CLI Errors
    case commandNotRecognized
    case tooManyArguments
    case emptyEntry
    
    // MARK: - User Termination Errors
    case overwriteCancelled
    
    // MARK: - Format Errors
    case invalidEntryFormat
    case invalidBranchValidatorFormat
    case invalidBranchPrefix(validator: String)
    case invalidYesOrNoFormat
    
    // MARK: - Dependency Location Errors
    case notAGitRepo(currentLocation: String)
    case directoryNotFound(name: String, path: String)
    case branchValidatorNotFound
    
    // MARK: - Read/Write Errors
    case cpFileIOError
    case hookFileIOError
    case headFileIOError
    
    var message: ConslerOutput {
        switch self {
            
        case .commandNotRecognized:
            return ConslerOutput(
                "Error: ", "Command not recognized. Enter ", "\"--help\"", " for usage.")
                .describedBy(.boldRed, .normal, .cyan)
            
        case .tooManyArguments:
            return ConslerOutput(
                "Error: ", "Too many arguments entered. Only two at a time is supported.")
                .describedBy(.boldRed)
            
        case .emptyEntry:
            return ConslerOutput("Error: ", "Your entry is empty.").describedBy(.boldRed)
            
        case .overwriteCancelled:
            return ConslerOutput("Error: ", "Overwrite is cancelled").describedBy(.boldRed)
            
        case .invalidEntryFormat:
            return ConslerOutput("Error: ", "Your entry contains invalid spaces.")
                .describedBy(.boldRed)
            
        case .invalidBranchValidatorFormat:
            return ConslerOutput(
                "Error: ", "The branch validator must be at least two characters long ",
                "and contain no numbers or spaces")
                .describedBy(.boldRed)
            
        case .invalidBranchPrefix(validator: let validator):
            return ConslerOutput(
                "Error: ", "Your branch does not begin with", " \(validator)", " and is invalid.",
                "Either: ", "change your branch name", " or ", "use commitPrefix in MODE NORMAL.")
                .describedBy(.boldRed, .normal, .yellow, .endsLine, .normal, .cyan, .normal, .cyan)
            
        case .invalidYesOrNoFormat:
            return ConslerOutput("Error: ", "Expected y or n. The transaction has been cancelled.")
                .describedBy(.boldRed)
            
        case .notAGitRepo(currentLocation: let location):
            return ConslerOutput(
                "Error: ", "Not in a git repo or at the root of one: ", "\(location)")
                .describedBy(.boldRed, .normal, .yellow)
            
        case .directoryNotFound(name: let name, path: let path):
            return ConslerOutput(
                "Error: ", "Directory named ", "\(name)", " was not found at ", "\(path)")
                .describedBy(.boldRed, .normal, .yellow, .normal, .yellow)
            
        case .branchValidatorNotFound:
            return ConslerOutput(
                "Error: ", "Attempting to provide a branch prefix without a branch validator")
                .describedBy(.boldRed)
            
        case .cpFileIOError:
            return ConslerOutput(
                "Error: ", "An error occured while reading or writing to the CommitPrefix files")
                .describedBy(.boldRed)
            
        case .hookFileIOError:
            return ConslerOutput(
                "Error: ", "An error occured while reading or writing to the commit-msg hook")
                .describedBy(.boldRed)
            
        case .headFileIOError:
            return ConslerOutput("Error: ", "Unable to read the git HEAD for branch information")
                .describedBy(.boldRed)
        }
        
    }
    
    var status: TerminationStatus {
        switch self {
        case .commandNotRecognized:
            return .invalidInputs
        case .tooManyArguments:
            return .invalidInputs
        case .emptyEntry:
            return .invalidInputs
        case .overwriteCancelled:
            return .userInitiated
        case .invalidEntryFormat:
            return .invalidInputs
        case .invalidBranchValidatorFormat:
            return .invalidInputs
        case .invalidBranchPrefix:
            return .invalidContext
        case .invalidYesOrNoFormat:
            return .invalidInputs
        case .notAGitRepo:
            return .unavailableDependencies
        case .directoryNotFound:
            return .unavailableDependencies
        case .branchValidatorNotFound:
            return .unavailableDependencies
        case .cpFileIOError:
            return .unavailableDependencies
        case .hookFileIOError:
            return .unavailableDependencies
        case .headFileIOError:
            return .unavailableDependencies
        }
        
    }
    
}
