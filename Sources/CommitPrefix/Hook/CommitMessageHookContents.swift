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
    
    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: Date())
    }
    
    func renderScript() -> String { """
        #!/usr/bin/swift
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
    }
    
    private func renderEnumIOError() -> String { """
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
        """
    }
    
    private func renderStructIOCommitPrefix() -> String { """
        struct IOCommitPrefix {
            
            let commitMsgPath: String
            
            init(filePath: [String] = Array(CommandLine.arguments.dropFirst())) throws {
                guard let firstArg = filePath.first else { throw IOError.invalidArgument }
                self.commitMsgPath = firstArg
            }
            
            \(renderIOCPMethodGetPrefixes())
            
            \(renderIOCPMethodGetCommitMessage())
        
            \(renderIOCPMethodOverwriteContents())
            
        }
        """
    }
    
    private func renderIOCPMethodGetPrefixes() -> String { """
        func getPrefixes() -> String {
            let readProcess = Process()
            readProcess.launchPath = "/usr/bin/env"
            readProcess.arguments = ["commitPrefix", "-o"]
            
            let pipe = Pipe()
            readProcess.standardOutput = pipe
            readProcess.launch()
            
            readProcess.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let contents = String(data: data, encoding: .utf8)
            
            return contents ?? ""
        }
        """
    }
    
    private func renderIOCPMethodGetCommitMessage() -> String { """
        func getCommitMessage() -> String {
            let readProcess = Process()
            readProcess.launchPath = "/usr/bin/env"
            readProcess.arguments = ["cat", commitMsgPath]
            
            let pipe = Pipe()
            readProcess.standardOutput = pipe
            readProcess.launch()
            
            readProcess.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let contents = String(data: data, encoding: .utf8)
            
            return contents ?? ""
        }
        """
    }
    
    private func renderIOCPMethodOverwriteContents() -> String { """
        func overwriteContents(with contents: String) throws {
            do {
                try contents.write(toFile: commitMsgPath, atomically: true, encoding: .utf8)
            } catch {
                throw IOError.overwriteError
            }
        }
        """
    }
    
    private func renderMainDoTryCatch() -> String { """
        do {
            
            let ioCommitPrefix = try IOCommitPrefix()
            
            let prefixes = ioCommitPrefix.getPrefixes()
                .trimmingCharacters(in: .newlines)
            
            let commitMessage = ioCommitPrefix.getCommitMessage()
                .trimmingCharacters(in: .newlines)
            
            let newCommitMessage = [prefixes, commitMessage].joined(separator: " ")
            try ioCommitPrefix.overwriteContents(with: newCommitMessage)
            
        } catch let ioError as IOError {
            
            print(ioError)
            
        }
        """
    }
    
}
