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

import enum CLInterface.TerminationStatus
import Consler
import Foundation

enum CPError: Error {
    
    // MARK: - User Termination Errors
    case overwriteCancelled
    
    // MARK: - Format Errors
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
    
    // MARK: - Uncategorized Error
    case unexpectedError
    
    var message: ConslerOutput {
        switch self {
            
        case .overwriteCancelled:
            return ConslerOutput("Error: ", "Overwrite is cancelled").describedBy(.red(.bold))
            
        case .invalidBranchValidatorFormat:
            return ConslerOutput(
                "Error: ", "The branch validator must be at least two characters long ",
                "and contain no numbers or spaces")
                .describedBy(.red(.bold))
            
        case .invalidBranchPrefix(validator: let validator):
            return ConslerOutput(
                "Error: ", "Your branch does not begin with", " \(validator)", " and is invalid.",
                "Either: ", "change your branch name", " or ", "use commitPrefix in MODE NORMAL.")
                .describedBy(.red(.bold), .normal, .yellow, .endsLine, .normal, .cyan, .normal, .cyan)
            
        case .invalidYesOrNoFormat:
            return ConslerOutput("Error: ", "Expected y or n. The transaction has been cancelled.")
                .describedBy(.red(.bold))
            
        case .notAGitRepo(currentLocation: let location):
            return ConslerOutput(
                "Error: ", "Not in a git repo or at the root of one: ", "\(location)")
                .describedBy(.red(.bold), .normal, .yellow)
            
        case .directoryNotFound(name: let name, path: let path):
            return ConslerOutput(
                "Error: ", "Directory named ", "\(name)", " was not found at ", "\(path)")
                .describedBy(.red(.bold), .normal, .yellow, .normal, .yellow)
            
        case .branchValidatorNotFound:
            return ConslerOutput(
                "Error: ", "Attempting to provide a branch prefix without a branch validator")
                .describedBy(.red(.bold))
            
        case .cpFileIOError:
            return ConslerOutput(
                "Error: ", "An error occured while reading or writing to the CommitPrefix files")
                .describedBy(.red(.bold))
            
        case .hookFileIOError:
            return ConslerOutput(
                "Error: ", "An error occured while reading or writing to the commit-msg hook")
                .describedBy(.red(.bold))
            
        case .headFileIOError:
            return ConslerOutput("Error: ", "Unable to read the git HEAD for branch information")
                .describedBy(.red(.bold))
            
        case .unexpectedError:
            return ConslerOutput("Error: ", "An uncategorized error has occured")
                .describedBy(.red(.bold))
        }
        
    }
    
    var status: TerminationStatus {
        switch self {
        case .overwriteCancelled:
            return .userInitiated
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
        case .unexpectedError:
            return .unexpectedError
        }
        
    }
    
}

extension Result where Failure == CPError {
    
    func resolveOrExit() -> Success {
        switch self {
        case let .success(value):
            return value
        case let .failure(cpError):
            Consler.output(cpError.message, type: .error)
            exit(cpError.status.value)
        }
    }
    
}
