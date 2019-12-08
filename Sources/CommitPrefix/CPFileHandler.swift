//
//  CPFileHandler.swift
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
import Files

public struct CPFileHandler {
    
    private let commitPrefixFile: File
    private let commitMessageHook: CommitMessageHook
    
    public init() throws {
        let currentDirectory = Folder.current
        let correctLocation = currentDirectory.containsSubfolder(named: FolderName.git)
        guard correctLocation else {
            throw CPError.notAGitRepo(currentLocation: currentDirectory.path)
        }
        let gitDirectory = try currentDirectory.subfolder(named: FolderName.git)
        self.commitPrefixFile = try gitDirectory.createFileIfNeeded(withName: FileName.commitPrefix)
        self.commitMessageHook = try CommitMessageHook(gitDirectory: gitDirectory)
    }
    
    public func locateOrCreateHook() throws {
        try commitMessageHook.locateOrCreateHook()
    }
    
    public func outputPrefix() throws -> String {
        let contents = try? commitPrefixFile.readAsString(encodedAs: .utf8)
        guard let readContents = contents else {
            throw CPError.fileReadWriteError
        }
        return readContents
    }
    
    public func deletePrefix() throws -> String {
        do {
            try commitPrefixFile.write("", encoding: .utf8)
        } catch {
            throw CPError.fileReadWriteError
        }
        return "CommitPrefix Deleted"
    }
    
    public func writeNew(prefix: String) throws -> String {
        let bracketSet = CharacterSet(charactersIn: "[]")
        let debracketedPrefix = prefix.trimmingCharacters(in: bracketSet)
        let formattedPrefix = "[\(debracketedPrefix)]"
        do {
            try commitPrefixFile.write(formattedPrefix, encoding: .utf8)
        } catch {
            throw CPError.fileReadWriteError
        }
        return formattedPrefix
    }
    
}
