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

import Consler
import Files
import Foundation

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
    
    static func create(_ gitDirectory: Folder) -> Result<CPInteractor, CPError> {
        do {
            let cpInteractor = try CPInteractor(gitDirectory: gitDirectory)
            return .success(cpInteractor)
        } catch let cpError as CPError {
            return .failure(cpError)
        } catch {
            return .failure(.unexpectedError)
        }
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
            throw CPError.cpFileIOError
        }
    }
    
    private func saveCommitPrefix(model: CPModel) -> Result<Void, CPError> {
        do {
            let jsonEncoder = JSONEncoder()
            let modelData = try jsonEncoder.encode(model)
            try commitPrefixFile.write(modelData)
            return .success(())
        } catch {
            cpDebugPrint(error)
            return .failure(.cpFileIOError)
        }
    }
    
    private func branchPrefixes() -> Result<[String], CPError> {
        guard let regexValue = commitPrefixModel.regexValue else {
            return .failure(.branchValidatorNotFound)
        }
        
        guard let branch = try? gitHEADFile.readAsString(encodedAs: .utf8) else {
            return .failure(.headFileIOError)
        }
        
        let matches = branch.occurances(ofRegex: regexValue)
        
        guard matches.count > 0 else {
            let validator = commitPrefixModel.branchValidator ?? "Validator Not Present"
            return .failure(.invalidBranchPrefix(validator: validator))
        }
        
        let uniqueMatches = Set(matches)
        return .success(Array(uniqueMatches))
    }
    
    private func prefixFormatter(_ rawValue: String) -> [String] {
        let parsedValues = rawValue
            .split(separator: ",")
            .map { String($0) }
        
        return parsedValues.map { "[\($0)]" }
    }
    
    private func validatorFormatter(_ rawValue: String) ->  Result<String, CPError> {
        let validator = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let containsNoNumbers = validator.occurances(ofRegex: #"(\d+)"#).isEmpty
        let atLeastTwoCharacters = validator.count > 1
        guard containsNoNumbers && atLeastTwoCharacters else {
            return .failure(.invalidBranchValidatorFormat)
        }
        return .success(validator)
    }
    
    func outputPrefixes() -> Result<ConslerOutput, CPError> {
        switch commitPrefixModel.prefixMode {
        case .normal:
            return .success(ConslerOutput(commitPrefixModel.prefixes.joined()))
        case .branchParse:
            return branchPrefixes().map {
                let branchPrefixes = $0.map { "[\($0)]" }.joined()
                let normalPrefixes = commitPrefixModel.prefixes.joined()
                return ConslerOutput(branchPrefixes, normalPrefixes)
            }
        }
    }
    
    func getCommitPrefixState() -> Result<CPState, CPError> {
        switch commitPrefixModel.prefixMode {
        case .normal:
            return .success(CPState(
                mode: .normal,
                branchPrefixes: [],
                normalPrefixes: commitPrefixModel.prefixes
            ))
        case .branchParse:
            return branchPrefixes().map {
                let branchPrefixes = $0.map { "[\($0)]" }
                let normalPrefixes = commitPrefixModel.prefixes
                return CPState(
                    mode: .branchParse,
                    branchPrefixes: branchPrefixes,
                    normalPrefixes: normalPrefixes
                )
            }
        }
    }
    
    func deletePrefixes() -> Result<ConslerOutput, CPError> {
        let newModel = commitPrefixModel.updated(with: [])
        return saveCommitPrefix(model: newModel)
            .transform(ConslerOutput(
                "CommitPrefix ", "DELETED")
                .describedBy(.normal, .red))
    }
    
    func writeNew(prefixes rawValue: String) -> Result<ConslerOutput, CPError> {
        let newPrefixes = prefixFormatter(rawValue)
        let newModel = commitPrefixModel.updated(with: newPrefixes)
        return saveCommitPrefix(model: newModel)
            .transform(ConslerOutput(
                "CommitPrefix ", "STORED ", newPrefixes.joined())
                .describedBy(.normal, .green, .green))
    }
    
    func activateBranchMode(with validator: String) -> Result<ConslerOutput, CPError> {
        switch validatorFormatter(validator) {
        case let .success(formattedValidator):
            let newModel = commitPrefixModel.updatedAsBranchMode(with: formattedValidator)
            return saveCommitPrefix(model: newModel)
                .transform(ConslerOutput(
                    "CommitPrefix ","MODE BRANCH_PARSE ", formattedValidator)
                    .describedBy(.normal, .cyan, .green))
        case let .failure(cpError):
            return .failure(cpError)
        }
    }
    
    func activateNormalMode() -> Result<ConslerOutput, CPError> {
        switch commitPrefixModel.prefixMode {
        case .normal:
            return .success(ConslerOutput("CommitPrefix ", "already in ", "MODE NORMAL")
                .describedBy(.normal, .yellow, .cyan))
        case .branchParse:
            let newModel = commitPrefixModel.updatedAsNormalMode()
            return saveCommitPrefix(model: newModel)
                .transform(ConslerOutput(
                    "CommitPrefix ", "MODE NORMAL")
                    .describedBy(.normal, .cyan))
        }
    }
    
}
