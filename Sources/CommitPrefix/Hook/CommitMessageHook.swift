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

import Consler
import Files
import Foundation
import FoundationExt

struct CommitMessageHook {
    
    private let hooksDirectory: Folder
    private let cmHookContents: CommitMessageHookContents
    
    private init(gitDirectory: Folder) throws {
        guard let hooksDirectory = try? gitDirectory.subfolder(named: FolderName.hooks) else {
            throw CPError.directoryNotFound(name: FolderName.hooks, path: gitDirectory.path)
        }
        self.hooksDirectory = hooksDirectory
        self.cmHookContents = CommitMessageHookContents()
    }
    
    /// A commit-message hook is required for this application to work properly. This method
    /// checks to see if the hook can be located, if it is one that is generated by this
    /// application and then generates one if it can't be found.
    ///
    /// - parameters:
    ///     - gitDirectory: A  `Folder` representing the git directory
    ///
    static func findOrCreate(with gitDirectory: Folder) -> Result<Void, CPError> {
        do {
            let cpHook = try CommitMessageHook(gitDirectory: gitDirectory)
            return cpHook.locateOrCreateHook()
        } catch let cpError as CPError {
            return .failure(cpError)
        } catch {
            return .failure(.unexpectedError)
        }

    }
    
    private func getCommitHookFile() -> Result<File, CPError> {
        
        guard let foundCommitHookFile = try? hooksDirectory.file(named: FileName.commitMessage) else {
        
            do {
                let commitHookFile = try hooksDirectory.createFile(named: FileName.commitMessage)
                try commitHookFile.write(cmHookContents.renderScript(), encoding: .utf8)
                cpDebugPrint(commitHookFile.path)
                Shell.makeExecutable(commitHookFile.path)
                return .success(commitHookFile)
            } catch {
                return .failure(.hookFileIOError)
            }
            
        }
        
        return .success(foundCommitHookFile)
        
    }
    
    private func overwriteCommitHook(_ commitHookFile: File) -> Result<Void, CPError> {
        Consler.output(
            ["", "There seems to be an existing commit-msg found in the hooks directory",
            "- Would you like to overwrite? [y/n]", ""],
            descriptors: [.endsLine, .yellowEndsLine, .yellow])
        
        let answer = readLine() ?? ""
        
        switch answer {
            
        case "y":
            Consler.output(
                ["","Overwriting existing commit-msg with generated hook", ""],
                descriptors: [.endsLine, .cyanEndsLine])
            
            do {
                // TODO: - Theres a case where the file is not executable in the first place this will not correct that
                try commitHookFile.write(cmHookContents.renderScript(), encoding: .utf8)
                return .success(())
            } catch {
                return .failure(.hookFileIOError)
            }
            
        case "n":
            return .failure(.overwriteCancelled)
            
        default:
            return .failure(.invalidYesOrNoFormat)
            
        }
    }
    
    private var hookIsCommitPrefix: (File) -> Result<(File, Bool), CPError> {
        return { hookFile in
            guard let hookContents = try? hookFile.readAsString(encodedAs: .utf8) else {
                return .failure(.hookFileIOError)
            }
            return .success((hookFile, hookContents.contains(self.cmHookContents.fileIdentifier)))
        }
    }
    
    private var shouldOverwriteHook: (File, Bool) -> Result<Void, CPError> {
        return { $1 ? .success(()) : self.overwriteCommitHook($0) }
    }
    
    private func locateOrCreateHook() -> Result<Void, CPError> {
        return getCommitHookFile()
            .flatMap(hookIsCommitPrefix)
            .flatMap(shouldOverwriteHook)
    }
    
}
