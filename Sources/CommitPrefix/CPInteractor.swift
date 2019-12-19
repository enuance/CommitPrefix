//
//  CPInteractor.swift
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

struct CPInteractor {
    
    private let commitPrefixFile: File
    private let commitPrefixModel: CPModel
    private let gitHEADFile: File
    
    init (gitDirectory: Folder) throws {
        let (commitPrefixFile, commitPrefixModel, gitHEADFile) = try Self.build(using: gitDirectory)
        self.commitPrefixFile = commitPrefixFile
        self.commitPrefixModel = commitPrefixModel
        self.gitHEADFile = gitHEADFile
    }
    
    private static func build(using gitDirectory: Folder) throws -> (File, CPModel, File) {
        do {
            let initialModelData = try JSONEncoder().encode(CPModel.empty())
            let cpFile = try gitDirectory.createFileIfNeeded(
                withName: FileName.commitPrefix,
                contents: initialModelData
            )
            let cpFileData = try cpFile.read()
            let cpModel = try JSONDecoder().decode(CPModel.self, from: cpFileData)
            let headFile = try gitDirectory.file(named: "HEAD")
            return (cpFile, cpModel, headFile)
        } catch {
            cpDebugPrint(error)
            throw CPError.fileReadWriteError
        }
    }
    
    private func saveCommitPrefix(model: CPModel) throws {
        do {
            let jsonEncoder = JSONEncoder()
            let modelData = try jsonEncoder.encode(model)
            try commitPrefixFile.write(modelData)
        } catch {
            cpDebugPrint(error)
            throw CPError.fileReadWriteError
        }
    }
    
    private func branchPrefixes() throws -> [String] {
        guard let regexValue = commitPrefixModel.regexValue else {
            throw CPTermination.branchValidatorNotPresent
        }
        
        let branch = Shell.currentBranch() ?? ""
        let matches = branch.occurances(ofRegex: regexValue)
        
        guard matches.count > 0 else {
            let validator = commitPrefixModel.branchValidator ?? "Validator Not Present"
            throw CPTermination.invalidBranchPrefix(validator: validator)
        }
        
        let uniqueMatches = Set(matches)
        return Array(uniqueMatches)
    }
    
    private func prefixFormatter(_ rawValue: String) -> [String] {
        let parsedValues = rawValue
            .split(separator: ",")
            .map { String($0) }
        
        return parsedValues.map { "[\($0)]" }
    }
    
    private func validatorFormatter(_ rawValue: String) throws ->  String {
        let validator = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let containsNoNumbers = validator.occurances(ofRegex: #"(\d+)"#).isEmpty
        let atLeastTwoCharacters = validator.count > 1
        guard containsNoNumbers && atLeastTwoCharacters else {
            throw CPError.branchValidatorFormatError
        }
        return validator
    }
    
    func outputPrefixes() throws -> String {
        switch commitPrefixModel.prefixMode {
        case .normal:
            return commitPrefixModel.prefixes.joined()
        case .branchParse:
            let retrievedBranchPrefixes = try branchPrefixes()
            let branchPrefixes = retrievedBranchPrefixes.map { "[\($0)]" }.joined()
            let normalPrefixes = commitPrefixModel.prefixes.joined()
            return branchPrefixes + normalPrefixes
        }
    }
    
    func getCommitPrefixState() throws -> CPState {
        switch commitPrefixModel.prefixMode {
        case .normal:
            return CPState(
                mode: .normal,
                branchPrefixes: [],
                normalPrefixes: commitPrefixModel.prefixes
            )
        case .branchParse:
            let retrievedBranchPrefixes = try branchPrefixes()
            let branchPrefixes = retrievedBranchPrefixes.map { "[\($0)]" }
            let normalPrefixes = commitPrefixModel.prefixes
            return CPState(
                mode: .branchParse,
                branchPrefixes: branchPrefixes,
                normalPrefixes: normalPrefixes
            )
        }
    }
    
    func deletePrefixes() throws -> String {
        let newModel = commitPrefixModel.updated(with: [])
        try saveCommitPrefix(model: newModel)
        return "CommitPrefix DELETED"
    }
    
    func writeNew(prefixes rawValue: String) throws -> String {
        let newPrefixes = prefixFormatter(rawValue)
        let newModel = commitPrefixModel.updated(with: newPrefixes)
        try saveCommitPrefix(model: newModel)
        return "CommitPrefix STORED \(newPrefixes.joined())"
    }
    
    func activateBranchMode(with validator: String) throws -> String {
        let formattedValidator = try validatorFormatter(validator)
        let newModel = commitPrefixModel.updatedAsBranchMode(with: formattedValidator)
        try saveCommitPrefix(model: newModel)
        return "CommitPrefix MODE BRANCH_PARSE \(formattedValidator)"
    }
    
    func activateNormalMode() throws -> String {
        switch commitPrefixModel.prefixMode {
        case .normal:
            return "CommitPrefix already in MODE NORMAL"
        case .branchParse:
            let newModel = commitPrefixModel.updatedAsNormalMode()
            try saveCommitPrefix(model: newModel)
            return "CommitPrefix MODE NORMAL"
        }
    }
    
}
