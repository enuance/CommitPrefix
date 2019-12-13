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
    
    private let cpInteractor: CPInteractor
    
    public init() throws {
        guard Folder.current.containsSubfolder(named: FolderName.git) else {
            throw CPError.notAGitRepo(currentLocation: Folder.current.path)
        }
        let gitDirectory = try Folder.current.subfolder(named: FolderName.git)
        self.cpInteractor = try CPInteractor(gitDirectory: gitDirectory)
        try CommitMessageHook.findOrCreate(with: gitDirectory)
    }
    
    public func outputPrefixes() throws -> String {
        try cpInteractor.outputPrefixes()
    }
    
    public func viewState() throws -> String {
        let cpState = try cpInteractor.getCommitPrefixState()
        switch cpState.mode {
        case .normal:
            return """
            CommitPrefix MODE NORMAL
            - prefixes: \(cpState.normalPrefixes.joined())
            """
        case .branchParse:
            return """
            CommitPrefix MODE BRANCH_PARSE
            - branch prefixes: \(cpState.branchPrefixes.joined())
            - stored prefixes: \(cpState.normalPrefixes.joined())
            """
        }
    }
    
    public func deletePrefixes() throws -> String {
        try cpInteractor.deletePrefixes()
    }
    
    public func writeNew(prefixes rawValue: String) throws -> String {
        try cpInteractor.writeNew(prefixes: rawValue)
    }
    
    public func activateBranchMode(with validator: String) throws -> String {
        try cpInteractor.activateBranchMode(with: validator)
    }
    
    public func activateNormalMode() throws -> String {
        try cpInteractor.activateNormalMode()
    }
    
}
