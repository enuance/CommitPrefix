//
//  CLIArguments.swift
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
import SPMUtility

public struct CLIArguments {

    public enum UserCommand {
        case viewState
        case outputPrefixes
        case deletePrefixes
        case modeNormal
        case modeBranchParse(validator: String)
        case newPrefixes(value: String)
    }
    
    private enum ParsedCommand {
        case viewState
        case outputPrefixes
        case deletePrefixes
        case modeNormal
        case modeBranchParse
        case userEntry(value: String)
    }
    
    private let parser: ArgumentParser
    private let rawArgs: [String]

    private let outputPrefixes: OptionArgument<Bool>
    private let deletePrefixes: OptionArgument<Bool>
    private let modeNormal: OptionArgument<Bool>
    private let modeBranchParse: OptionArgument<Bool>
    private let userEntry: PositionalArgument<[String]>

    public init(arguments: [String] = CommandLine.arguments) {
        // The first argument specifies the path of the executable file
        self.rawArgs = Array(arguments.dropFirst())
        let argBuilder = ArgumentBuilder()
        self.parser = argBuilder.buildParser()
        
        self.outputPrefixes = argBuilder.buildOutputArgument(parser: parser)
        self.deletePrefixes = argBuilder.buildDeleteArgument(parser: parser)
        self.modeNormal = argBuilder.buildNormalArgument(parser: parser)
        self.modeBranchParse = argBuilder.buildBranchParseArgument(parser: parser)
        self.userEntry = argBuilder.buildUserEntryArgument(parser: parser)
    }

    private func singleCommandParse(_ allCommands: [ParsedCommand]) throws -> UserCommand {
        precondition(allCommands.count == 1, "Intended for single Parsed Command only!")
        guard let foundCommand = allCommands.first else {
            throw CPError.userCommandNotRecognized
        }
        
        switch foundCommand {
        case .outputPrefixes:
            return .outputPrefixes
        case .deletePrefixes:
            return .deletePrefixes
        case .modeNormal:
            return .modeNormal
        case .userEntry(value: let prefixes):
            return .newPrefixes(value: prefixes)
        default:
            throw CPError.userCommandNotRecognized
        }
    }
    
    private func doubleCommandParse(_ allCommands: [ParsedCommand]) throws -> UserCommand {
        precondition(allCommands.count == 2, "Intended for two Parsed Commands only!")
        let firstCommand = allCommands[0]
        let secondCommand = allCommands[1]
        
        switch (firstCommand, secondCommand) {
        case (.modeBranchParse, .userEntry(value: let validator)):
            return .modeBranchParse(validator: validator)
        case (.userEntry(value: let validator), .modeBranchParse):
            return .modeBranchParse(validator: validator)
        default:
            throw CPError.userCommandNotRecognized
        }
    }
    
    func getCommand() throws -> UserCommand {
        guard let parsedArgs = try? parser.parse(rawArgs) else {
            throw CPError.userCommandNotRecognized
        }
        
        var allCommands = [ParsedCommand]()
        
        parsedArgs.get(outputPrefixes).map { _ in allCommands.append(.outputPrefixes) }
        parsedArgs.get(deletePrefixes).map { _ in allCommands.append(.deletePrefixes) }
        parsedArgs.get(modeNormal).map { _ in allCommands.append(.modeNormal) }
        parsedArgs.get(modeBranchParse).map { _ in allCommands.append(.modeBranchParse) }
        
        try parsedArgs.get(userEntry).map { userEntry in
            let noMoreThanOneEntry = userEntry.count < 2
            guard noMoreThanOneEntry else { throw CPError.newEntryShouldNotHaveSpaces }
            guard let theEntry = userEntry.first else { throw CPError.emptyEntry }
            allCommands.append(.userEntry(value: theEntry))
        }
        
        switch allCommands.count {
        case 0:
            return .viewState
        case 1:
            return try singleCommandParse(allCommands)
        case 2:
            return try doubleCommandParse(allCommands)
        default:
            throw CPError.multipleArguments
        }
        
    }
    
}

private struct ArgumentBuilder {

    let usage: String = """
    <Commit Prefix Description>
    """
    
    let overview: String = """
    The CommitPrefix stores a desired prefix for your commit messages.
    It stores it within the .git folder of the current repository. A
    commit-msg hook is also generated and stored within the .git
    folder which is used to prefix the commit message.
    """

    func buildParser() -> ArgumentParser {
        ArgumentParser(usage: usage, overview: overview)
    }
    
    func buildOutputArgument(parser: ArgumentParser) -> OptionArgument<Bool> {
        return parser.add(
            option: "--output",
            shortName: "-o",
            kind: Bool.self,
            usage: "Outputs the full, formated prefix to standard output",
            completion: nil
        )
    }
    
    func buildDeleteArgument(parser: ArgumentParser) -> OptionArgument<Bool> {
        return parser.add(
            option: "--delete",
            shortName: "-d",
            kind: Bool.self,
            usage: "Deletes the stored prefixes",
            completion: nil
        )
    }

    func buildNormalArgument(parser: ArgumentParser) -> OptionArgument<Bool> {
        return parser.add(
            option: "--normal",
            shortName: "-n",
            kind: Bool.self,
            usage: "Sets the mode to NORMAL",
            completion: nil
        )
    }
    
    func buildBranchParseArgument(parser: ArgumentParser) -> OptionArgument<Bool> {
        return parser.add(
            option: "--branchParse",
            shortName: "-b",
            kind: Bool.self,
            usage: "Sets the mode to BRANCH_PARSE. Requires a validator",
            completion: nil
        )
    }
    
    func buildUserEntryArgument(parser: ArgumentParser) -> PositionalArgument<[String]> {
        return parser.add(
            positional: "UserEntry",
            kind: [String].self,
            optional: true,
            usage: nil,
            completion: nil
        )
    }
    
}
