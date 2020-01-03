//
//  CommitMessageHookContents.swift
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

import Foundation

struct CommitMessageHookContents {
    
    let fileIdentifier = "Created by CommitPrefix \(CPInfo.version)"
    
    private let tab = "<tab>"
    
    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: Date())
    }
    
    func renderScript() -> String {
        let script = """
        #!/usr/bin/env swift
        //
        // Commit-msg
        //
        // \(fileIdentifier) on \(currentDate)
        //
        
        import Foundation
        
        \(renderEnumIOError())
        
        \(renderStructIOCommitPrefix())
        
        \(renderMainDoTryCatch())
        
        """
        
        return script.replacingOccurrences(of: tab, with: "    ")
    }
    
    private func renderEnumIOError() -> String { """
        enum IOError: Error {
            
        \(tab)case invalidArgument
        \(tab)case overwriteError
        \(tab)case commitPrefixError
            
        \(tab)var message: String {
        \(tab + tab)switch self {
        \(tab + tab)case .invalidArgument:
        \(tab + tab + tab)return "Intended to recieve .git/COMMIT_EDITMSG arg"
        \(tab + tab)case .overwriteError:
        \(tab + tab + tab)return "There was an error writting to the commit message"
        \(tab + tab)case .commitPrefixError:
        \(tab + tab + tab)return \"\"\"
        
        \(tab + tab + tab)- CommitPrefix Error
        \(tab + tab + tab)\"\"\"
        \(tab + tab)}
        \(tab)}
            
        }
        """
    }
    
    private func renderStructIOCommitPrefix() -> String { """
        struct IOCommitPrefix {
            
        \(tab)let commitMsgPath: String
            
        \(tab)init(filePath: [String] = Array(CommandLine.arguments.dropFirst())) throws {
        \(tab + tab)guard let firstArg = filePath.first else { throw IOError.invalidArgument }
        \(tab + tab)self.commitMsgPath = firstArg
        \(tab)}
            
        \(renderIOCPMethodGetPrefixes())
            
        \(renderIOCPMethodGetCommitMessage())
        
        \(renderIOCPMethodOverwriteContents())
        
        }
        """
    }
    
    private func renderIOCPMethodGetPrefixes() -> String { """
        \(tab)func getPrefixes() throws -> String {
        \(tab + tab)let readProcess = Process()
        \(tab + tab)readProcess.launchPath = "/usr/bin/env"
        
        \(tab + tab)var readProcessEnv = ProcessInfo.processInfo.environment
        \(tab + tab)let paths = readProcessEnv["PATH"]
        \(tab + tab)paths.map { readProcessEnv["PATH"] = "/usr/local/bin:\\($0)" }
        
        \(tab + tab)readProcess.environment = readProcessEnv
        \(tab + tab)readProcess.arguments = ["commitPrefix", "-o"]
            
        \(tab + tab)let pipe = Pipe()
        \(tab + tab)readProcess.standardOutput = pipe
        \(tab + tab)readProcess.launch()
            
        \(tab + tab)readProcess.waitUntilExit()
            
        \(tab + tab)if readProcess.terminationStatus != 0 {
        \(tab + tab + tab)throw IOError.commitPrefixError
        \(tab + tab)}
            
        \(tab + tab)let data = pipe.fileHandleForReading.readDataToEndOfFile()
        \(tab + tab)let contents = String(data: data, encoding: .utf8)
            
        \(tab + tab)return contents ?? ""
        \(tab)}
        """
    }
    
    private func renderIOCPMethodGetCommitMessage() -> String { """
        \(tab)func getCommitMessage() -> String {
        \(tab + tab)let readProcess = Process()
        \(tab + tab)readProcess.launchPath = "/usr/bin/env"
        \(tab + tab)readProcess.arguments = ["cat", commitMsgPath]
            
        \(tab + tab)let pipe = Pipe()
        \(tab + tab)readProcess.standardOutput = pipe
        \(tab + tab)readProcess.launch()
            
        \(tab + tab)readProcess.waitUntilExit()
            
        \(tab + tab)let data = pipe.fileHandleForReading.readDataToEndOfFile()
        \(tab + tab)let contents = String(data: data, encoding: .utf8)
            
        \(tab + tab)return contents ?? ""
        \(tab)}
        """
    }
    
    private func renderIOCPMethodOverwriteContents() -> String { """
        \(tab)func overwriteContents(with contents: String) throws {
        \(tab + tab)do {
        \(tab + tab + tab)try contents.write(toFile: commitMsgPath, atomically: true, encoding: .utf8)
        \(tab + tab)} catch {
        \(tab + tab + tab)throw IOError.overwriteError
        \(tab + tab)}
        \(tab)}
        """
    }
    
    private func renderMainDoTryCatch() -> String { """
        do {
            
        \(tab)let ioCommitPrefix = try IOCommitPrefix()
            
        \(tab)let prefixes = try ioCommitPrefix.getPrefixes()
        \(tab + tab).trimmingCharacters(in: .newlines)
            
        \(tab)let commitMessage = ioCommitPrefix.getCommitMessage()
        \(tab + tab).trimmingCharacters(in: .newlines)
            
        \(tab)let newCommitMessage = [prefixes, commitMessage].joined(separator: " ")
        \(tab)try ioCommitPrefix.overwriteContents(with: newCommitMessage)
            
        } catch let ioError as IOError {
            
        \(tab)print(ioError.message)
        \(tab)exit(1)
        
        }
        """
    }
    
}
