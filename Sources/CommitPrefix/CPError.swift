//
//  CPError.swift
//
//
//  Created by Stephen Martinez on 12/3/19.
//

import Foundation

enum CPError: Error {
    
    case userCommandNotRecognized
    case newEntryShouldNotHaveSpaces
    case emptyEntry
    case multipleArguments
    case notAGitRepo(currentLocation: String)
    case fileReadWriteError
    case directoryNotFound(name: String, path: String)
    case hookReadWriteError
    case expectedYesOrNo
    
    var message: String {
        switch self {
        case .userCommandNotRecognized:
            return "Command not recognized. Enter \"--help\" for usage."
        case .newEntryShouldNotHaveSpaces:
            return "Your entry contains invalid spaces."
        case .emptyEntry:
            return "Your entry is empty."
        case .multipleArguments:
            return "Multiple arguments entered. Only one at a time is supported."
        case .notAGitRepo(currentLocation: let location):
            return "Not in a git repo or at the root of one: \(location)"
        case .fileReadWriteError:
            return "An error occured while reading or writing to the CommitPrefix files"
        case .directoryNotFound(name: let name, path: let path):
            return "Directory named \(name) was not found at \(path)"
        case .hookReadWriteError:
            return "An error occured while reading or writing to the commit-msg hook"
        case .expectedYesOrNo:
            return "expected y or n. The transaction has been cancelled."
        }
        
    }
    
}
