//
//  CommitMessageHook.swift
//
//
//  Created by Stephen Martinez on 12/5/19.
//

import Files
import Foundation

public struct CommitMessageHook {
    
    private let fileIdentifier = "Created by CommitPrefix"
    
    private let hooksDirectory: Folder
    
    public init(gitDirectory: Folder) throws {
        guard let hooksDirectory = try? gitDirectory.subfolder(named: FolderName.hooks) else {
            throw CPError.directoryNotFound(name: FolderName.hooks, path: gitDirectory.path)
        }
        self.hooksDirectory = hooksDirectory
    }
    
    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: Date())
    }

    private var contents: String { """
        #!/bin/sh
        #
        # Commit-msg
        #
        # \(fileIdentifier) on \(currentDate)
        #
        
        # Get the current directory and store it
        currentDirectory=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
        
        # Locate the Commit Prefix file and read/store its contents
        prefix=$( echo $( cat $currentDirectory/../commitPrefix.txt ) )
        
        # Read and store the contents of the original commit message
        message=$( echo $( cat $1 ) )
        
        # Build the prepended message and overwrite the commit message
        echo "$( echo $prefix ) $( echo $message )" > $1
        """
    }
    
    private func makeExecutable(_ fileName: String) {
        let executableProcess = Process()
        executableProcess.launchPath = "/usr/bin/env"
        cpDebugPrint(executableProcess.launchPath ?? "nil")
        executableProcess.arguments = ["chmod", "755", fileName]
        
        let pipe = Pipe()
        executableProcess.standardOutput = pipe
        executableProcess.launch()
        
        executableProcess.waitUntilExit()
    }
    
    private func getCommitHookFile() throws -> File? {
        
        guard let foundCommitHookFile = try? hooksDirectory.file(named: FileName.commitMessage) else {
        
            do {
                let commitHookFile = try hooksDirectory.createFile(named: FileName.commitMessage)
                try commitHookFile.write(contents, encoding: .utf8)
                cpDebugPrint(commitHookFile.path)
                makeExecutable(commitHookFile.path)
            } catch {
                throw CPError.hookReadWriteError
            }
            
            return nil
            
        }
        
        return foundCommitHookFile
        
    }
    
    private func overwriteCommitHook(_ commitHookFile: File) throws {
        print("There seems to be an existing commit-msg found in the hooks directory")
        print("Would you like to overwrite? [y/n]")
        let answer = readLine() ?? ""
        
        switch answer {
            
        case "y":
            print("Overwritting existing commit-msg with generated hook")
            
            do {
                try commitHookFile.write(contents, encoding: .utf8)
            } catch {
                throw CPError.hookReadWriteError
            }
            
        case "n":
            print("Overwrite is cancelled")
            exit(0)
            
        default:
            
            throw CPError.expectedYesOrNo
            
        }
    }
    
    private func hookIsCommitPrefix(_ hookFile: File) throws -> Bool {
        
        guard let hookContents = try? hookFile.readAsString(encodedAs: .utf8) else {
            throw CPError.hookReadWriteError
        }
        
        return hookContents.contains(fileIdentifier)
    }
    
    public func locateOrCreateHook() throws {
        guard let foundCommitHookFile = try getCommitHookFile() else { return }
        guard try !hookIsCommitPrefix(foundCommitHookFile) else { return }
        try overwriteCommitHook(foundCommitHookFile)
    }
    
}
