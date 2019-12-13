//
//  CommitPrefixModel.swift
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

public enum PrefixMode: Int {
    
    case normal
    case branchParse
    
}

public struct CommitPrefixModel: Codable {
 
    let prefixMode: PrefixMode
    let branchValidator: String?
    let prefixes: [String]
    
    /// Provides a regex if a branch validator is present
    var regexValue: String? {
        return branchValidator.flatMap {
            return #"((?i)(\#($0))-(\d+))"#
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case prefixMode = "prefix_mode"
        case branchValidator = "branch_issue_validator"
        case prefixes = "prefixes"
    }
    
    private init(prefixMode: PrefixMode, branchValidator: String?, prefixes: [String]) {
        self.prefixMode = prefixMode
        self.branchValidator = branchValidator
        self.prefixes = prefixes
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let prefixModeRawValue = try values.decode(Int.self, forKey: .prefixMode)
        self.prefixMode = PrefixMode(rawValue: prefixModeRawValue) ?? PrefixMode.normal
        self.branchValidator = try values.decodeIfPresent(String.self, forKey: .branchValidator)
        self.prefixes = try values.decode([String].self, forKey: .prefixes)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(prefixMode.rawValue, forKey: .prefixMode)
        try container.encodeIfPresent(branchValidator, forKey: .branchValidator)
        try container.encode(prefixes, forKey: .prefixes)
    }
    
    static public func empty() -> CommitPrefixModel {
        return CommitPrefixModel(
            prefixMode: .normal,
            branchValidator: nil,
            prefixes: []
        )
    }
    
    public func updated(with newPrefixes: [String]) -> CommitPrefixModel {
        return CommitPrefixModel(
            prefixMode: prefixMode,
            branchValidator: branchValidator,
            prefixes: newPrefixes
        )
    }
    
    public func updatedAsBranchMode(with newBranchValidator: String) -> CommitPrefixModel {
        return CommitPrefixModel(
            prefixMode: .branchParse,
            branchValidator: newBranchValidator,
            prefixes: prefixes
        )
    }
    
    public func updatedAsNormalMode() -> CommitPrefixModel {
        return CommitPrefixModel(
            prefixMode: .normal,
            branchValidator: nil,
            prefixes: prefixes
        )
    }
    
}

public struct CommitPrefixState {
    let mode: PrefixMode
    let branchPrefixes: [String]
    let normalPrefixes: [String]
}
