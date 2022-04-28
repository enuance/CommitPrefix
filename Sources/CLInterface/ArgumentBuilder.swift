//
//  ArgumentBuilder.swift
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

struct ArgumentBuilder {

    let usage: String = """
    [<PrefixValue1>,<PrefixValue2>,<PrefixValue3>...] [-o | --output] [-d | --delete]
    [-n | -normal] [ -b | --branchParse <ValidatorValue> ] [-v | --version]
    """
    
    let overview: String = """

    The CommitPrefix stores a desired set of prefixes for your commit messages. It
    stores it within the .git folder of the current repository. A commit-msg hook is
    also generated and stored within the .git folder which is used to prefix the
    commit message.

    Modes:
    CommitPrefix has two modes, normal and branch parse.

    - NORMAL
    example: commitPrefix <PrefixValue1>,<PrefixValue2>,<PrefixValue3>...
    
    You can add normal prefixes by entering comma seperated values. These values will
    be parsed as prefixes and prepended to future commit messages.

    - BRANCH_PARSE
    example commitPrefix -b <ValidatorValue>
    
    Branch parse mode checks the current branch for an issue number validated by the
    value passed in as an argument. For example if you passed in a validator value of
    "eng" and your current branch was named ENG-342-SomeFeatureBranchLinkedToENG-101,
    commitPrefix will pickup [ENG-342] and [ENG-101] as branch prefixes to be
    prepended to you next commit along with any other normal prefixes you might have.
    
    You can change back to NORMAL mode by entering:
    example: commitPrefix -n

    To view the current state of prefixes and mode, enter:
    example: commitPrefix
    """

    func buildParser() -> ArgumentParser {
        ArgumentParser(usage: usage, overview: overview)
    }
    
    func buildVersionArgument(parser: ArgumentParser) -> OptionArgument<Bool> {
        return parser.add(
            option: "--version",
            shortName: "-v",
            kind: Bool.self,
            usage: "Outputs the current version information",
            completion: nil
        )
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
            usage: "Sets the mode to BRANCH_PARSE. Requires a validator argument",
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
