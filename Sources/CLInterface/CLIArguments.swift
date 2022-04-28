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
import TerminalController

public struct CLIArguments {

    public enum UserCommand {
        case outputVersion
        case viewState
        case outputPrefixes
        case deletePrefixes
        case modeNormal
        case modeBranchParse(validator: String)
        case newPrefixes(value: String)
    }
    
    private enum ParsedCommand {
        case outputVersion
        case viewState
        case outputPrefixes
        case deletePrefixes
        case modeNormal
        case modeBranchParse
        case userEntry(value: String)
    }
    
    private let parser: ArgumentParser
    private let rawArgs: [String]

    private let outputVersion: OptionArgument<Bool>
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
        
        self.outputVersion = argBuilder.buildVersionArgument(parser: parser)
        self.outputPrefixes = argBuilder.buildOutputArgument(parser: parser)
        self.deletePrefixes = argBuilder.buildDeleteArgument(parser: parser)
        self.modeNormal = argBuilder.buildNormalArgument(parser: parser)
        self.modeBranchParse = argBuilder.buildBranchParseArgument(parser: parser)
        self.userEntry = argBuilder.buildUserEntryArgument(parser: parser)
    }

    private func singleCommandParse(_ allCommands: [ParsedCommand]) -> Result<UserCommand, CLIError> {
        precondition(allCommands.count == 1, "Intended for single Parsed Command only!")
        guard let foundCommand = allCommands.first else {
            return .failure(.commandNotRecognized)
        }
        
        switch foundCommand {
        case .outputVersion:
            return .success(.outputVersion)
        case .outputPrefixes:
            return .success(.outputPrefixes)
        case .deletePrefixes:
            return .success(.deletePrefixes)
        case .modeNormal:
            return .success(.modeNormal)
        case .userEntry(value: let prefixes):
            return .success(.newPrefixes(value: prefixes))
        default:
            return .failure(.commandNotRecognized)
        }
    }
    
    private func doubleCommandParse(_ allCommands: [ParsedCommand]) -> Result<UserCommand, CLIError> {
        precondition(allCommands.count == 2, "Intended for two Parsed Commands only!")
        let firstCommand = allCommands[0]
        let secondCommand = allCommands[1]
        
        switch (firstCommand, secondCommand) {
        case (.modeBranchParse, .userEntry(value: let validator)):
            return .success(.modeBranchParse(validator: validator))
        case (.userEntry(value: let validator), .modeBranchParse):
            return .success(.modeBranchParse(validator: validator))
        default:
            return .failure(.commandNotRecognized)
        }
    }
    
    public func getCommand() -> Result<UserCommand, CLIError> {
        guard let parsedArgs = try? parser.parse(rawArgs) else {
            return .failure(.commandNotRecognized)
        }
        
        var allCommands = [ParsedCommand]()
        
        parsedArgs.get(outputVersion).map { _ in allCommands.append(.outputVersion) }
        parsedArgs.get(outputPrefixes).map { _ in allCommands.append(.outputPrefixes) }
        parsedArgs.get(deletePrefixes).map { _ in allCommands.append(.deletePrefixes) }
        parsedArgs.get(modeNormal).map { _ in allCommands.append(.modeNormal) }
        parsedArgs.get(modeBranchParse).map { _ in allCommands.append(.modeBranchParse) }
        
        do {
            try parsedArgs.get(userEntry).map { userEntry in
                let noMoreThanOneEntry = userEntry.count < 2
                guard noMoreThanOneEntry else { throw CLIError.invalidEntryFormat }
                guard let theEntry = userEntry.first else { throw CLIError.emptyEntry }
                allCommands.append(.userEntry(value: theEntry))
            }
        } catch let cliError as CLIError {
            return .failure(cliError)
        } catch {
            return .failure(.unexpectedError)
        }
        
        switch allCommands.count {
        case 0:
            return .success(.viewState)
        case 1:
            return singleCommandParse(allCommands)
        case 2:
            return doubleCommandParse(allCommands)
        default:
            return .failure(.tooManyArguments)
        }
        
    }
    
    public var command: UserCommand { getCommand().resolveOrExit() }
    
}
