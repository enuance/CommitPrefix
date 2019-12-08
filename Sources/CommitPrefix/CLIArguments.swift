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
        case delete
        case view
        case newEntry(entry: String)
    }
    
    private let parser: ArgumentParser
    private let rawArgs: [String]

    private let delete: OptionArgument<Bool>
    private let view: OptionArgument<Bool>
    private let newEntry: PositionalArgument<[String]>

    public init(arguments: [String] = CommandLine.arguments) {
        // The first argument specifies the path of the executable file
        self.rawArgs = Array(arguments.dropFirst())
        let argBuilder = ArgumentBuilder()
        self.parser = argBuilder.buildParser()
        self.delete = argBuilder.buildDeleteArgument(parser: parser)
        self.view = argBuilder.buildViewArgument(parser: parser)
        self.newEntry = argBuilder.buildNewEntryArgument(parser: parser)
    }

    func getCommand() throws -> UserCommand {
        guard let parsedArgs = try? parser.parse(rawArgs) else {
            throw CPError.userCommandNotRecognized
        }
        
        var allCommands = [UserCommand]()
        
        parsedArgs.get(delete).map { _ in allCommands.append(.delete) }
        parsedArgs.get(view).map { _ in allCommands.append(.view) }
        try parsedArgs.get(newEntry).map { userEntry in
            
            guard userEntry.count < 2 else {
                throw CPError.newEntryShouldNotHaveSpaces
            }
            
            guard let theEntry = userEntry.first else {
                throw CPError.emptyEntry
            }
            
            guard !theEntry.isEmpty else {
                throw CPError.emptyEntry
            }
            
            allCommands.append(.newEntry(entry: theEntry))
            
        }
        
        guard allCommands.count < 2 else {
            throw CPError.multipleArguments
        }
        
        guard let command = allCommands.first else {
            throw CPError.userCommandNotRecognized
        }
        
        return command
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

    func buildDeleteArgument(parser: ArgumentParser) -> OptionArgument<Bool> {
        return parser.add(
            option: "--delete",
            shortName: "-d",
            kind: Bool.self,
            usage: "Deletes the stored prefix",
            completion: nil
        )
    }

    func buildViewArgument(parser: ArgumentParser) -> OptionArgument<Bool> {
        return parser.add(
            option: "--view",
            shortName: "-v",
            kind: Bool.self,
            usage: "Display the currently stored prefix",
            completion: nil
        )
    }
    
    func buildNewEntryArgument(parser: ArgumentParser) -> PositionalArgument<[String]> {
        return parser.add(
            positional: "NewEntry",
            kind: [String].self,
            optional: true,
            usage: nil,
            completion: nil
        )
    }
    
}
