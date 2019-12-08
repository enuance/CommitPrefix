//
//  CommitMessageHook.swift
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

import Files
import Foundation

public struct CommitMessageHook {
    
    private let cpVersionNumber = "1.0.0"
    
    private let fileIdentifier = "Created by CommitPrefix \(cpVersionNumber)"
    
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
        #!/usr/bin/swift
        //
        // Commit-msg
        //
        // \(fileIdentifier) on \(currentDate)
        //
        
        import Foundation
        
        enum IOError: Error {
            
            case invalidArgument
            case overwriteError
            
            var message: String {
                switch self {
                case .invalidArgument:
                    return "Intended to recieve .git/COMMIT_EDITMSG arg"
                case .overwriteError:
                    return "There was an error writting to the commit message"
                }
            }
            
        }

        struct IOHelper {
            
            let commitMsgPath: String
            let prefixPath = ".git/CommitPrefix.txt"
            
            init(filePath: [String] = Array(CommandLine.arguments.dropFirst())) throws {
                guard let firstArg = filePath.first else {
                    throw IOError.invalidArgument
                }
                self.commitMsgPath = firstArg
            }
            
            func readContents(of filePath: String) -> String {
                let readProcess = Process()
                readProcess.launchPath = "/usr/bin/env"
                readProcess.arguments = ["cat", filePath]
                
                let pipe = Pipe()
                readProcess.standardOutput = pipe
                readProcess.launch()
                
                readProcess.waitUntilExit()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let contents = String(data: data, encoding: .utf8)
                
                return contents ?? ""
            }
            
            func overwriteContents(with contents: String) throws {
                do {
                    try contents.write(toFile: commitMsgPath, atomically: true, encoding: .utf8)
                } catch {
                    throw IOError.overwriteError
                }
            }
            
        }


        do {
            
            let helper = try IOHelper()
            
            let commitMessage = helper.readContents(of: helper.commitMsgPath)
                .trimmingCharacters(in: .newlines)
            
            let prefixMessage = helper.readContents(of: helper.prefixPath)
                .trimmingCharacters(in: .newlines)
            
            let newCommitMessage = [prefixMessage, commitMessage].joined(separator: " ")
            try helper.overwriteContents(with: newCommitMessage)
            
        } catch let ioError as IOError {
            
            print(ioError)
            
        }
        
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
