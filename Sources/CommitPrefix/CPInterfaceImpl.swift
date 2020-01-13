//
//  CPInterfaceImpl.swift
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

struct CommitPrefix {
    
    private init() {}
    
    static func interface() -> CPInterface { CommitPrefix() }
    
    private func getInteractor() -> Result<CPInteractor, CPError>  {
        
        guard
            Folder.current.containsSubfolder(named: FolderName.git),
            let gitDirectory = try? Folder.current.subfolder(named: FolderName.git)
            else { return .failure(.notAGitRepo(currentLocation: Folder.current.path)) }
        
        return CommitMessageHook
            .findOrCreate(with: gitDirectory)
            .transform(gitDirectory)
            .flatMap(CPInteractor.create)
        
    }
    
}

// MARK: - CPInterface Conformances
extension CommitPrefix: CPInterface {
    
    func outputPrefixes() -> ConslerOutput {
        return getInteractor()
            .flatMap { $0.outputPrefixes() }
            .resolveOrExit()
    }
    
    func outputVersion() -> ConslerOutput {
        return ConslerOutput(
            "CommitPrefix ", "version ", CPInfo.version)
            .describedBy(.normal, .cyan, .cyan)
    }
    
    func viewState() -> ConslerOutput {
        return getInteractor()
            .flatMap { $0.getCommitPrefixState() }
            .map { cpState in
                switch cpState.mode {
                case .normal:
                    return ConslerOutput(
                        "CommitPrefix ", "MODE NORMAL",
                        "- prefixes: ", cpState.normalPrefixes.joined())
                        .describedBy(.normal, .cyanEndsLine, .normal, .cyan)
                case .branchParse:
                    return ConslerOutput(
                        "CommitPrefix ", "MODE BRANCH_PARSE",
                        "- branch prefixes: ", cpState.branchPrefixes.joined(),
                        "- stored prefixes: ", cpState.normalPrefixes.joined())
                        .describedBy(.normal, .cyanEndsLine, .normal, .cyanEndsLine, .normal, .cyan)
                }
        }
        .resolveOrExit()
    }
    
    func deletePrefixes() -> ConslerOutput {
        return getInteractor()
            .flatMap { $0.deletePrefixes() }
            .resolveOrExit()
    }
    
    func writeNew(prefixes rawValue: String) -> ConslerOutput {
        return getInteractor()
            .flatMap { $0.writeNew(prefixes: rawValue) }
            .resolveOrExit()
    }
    
    func activateBranchMode(with validator: String) -> ConslerOutput {
        return getInteractor()
            .flatMap { $0.activateBranchMode(with: validator) }
            .resolveOrExit()
    }
    
    func activateNormalMode() -> ConslerOutput {
        return getInteractor()
            .flatMap { $0.activateNormalMode() }
            .resolveOrExit()
    }
    
}
