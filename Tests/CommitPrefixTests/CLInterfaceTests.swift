//
//  CLInterfaceTests.swift
//  commitPrefix
//
//  MIT License
//
//  Copyright (c) 2020 STEPHEN L. MARTINEZ
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

import CLInterface
import Foundation
import FoundationExt
import XCTest

final class CLInterfaceTests: XCTestCase {
    
    func test_SingleArgumentShortCommands() {
        CLITestArgument.singleArgs.forEach {
            CLITestUtil.assertOnProperSingleArg($0.proper)
        }
    }
    
    func test_SingleArgumentLongCommands() {
        CLITestArgument.singleArgs.forEach {
            CLITestUtil.assertOnProperSingleArg($0.proper, useLong: true)
        }
    }
    
    func test_FailingSingleArgumentShortCommands() {
        CLITestArgument.singleArgs.forEach {
            CLITestUtil.assertOnMalformedSingleArg($0.malformed)
        }
    }
    
    func test_FailingSingleArgumentLongCommands() {
        CLITestArgument.singleArgs.forEach {
            CLITestUtil.assertOnMalformedSingleArg($0.malformed, useLong: true)
        }
    }
    
    func test_ExtraArgsSingleArgumentShortCommands() {
        CLITestArgument.singleArgs.forEach {
            CLITestUtil.assertOnExtraArgsForSingleArg($0.proper, extraInput: $0.extraInput)
        }
    }
    
    func test_ExtraArgsSingleArgumentLongCommands() {
        CLITestArgument.singleArgs.forEach {
            CLITestUtil
                .assertOnExtraArgsForSingleArg($0.proper, extraInput: $0.extraInput, useLong: true)
        }
    }
    
    // Special Command that uses no args except for the standard default OS argument
    func test_ViewStateCommand() {
        let args = ["executable/location"]
        let argument = CLIArguments(arguments: args)
        let expectedCommand = UserCommand.viewState
        let failureMessage = "Expected no input to return an output of"
        + " \(expectedCommand.description)"
        
        print("⚖️  ~ Testing no arguments for command \(expectedCommand.description)")
        func validateCommand(foundCommand: UserCommand) -> Void {
            let isValid = UserCommand.isEquivelent(lhs: foundCommand, rhs: expectedCommand)
            XCTAssert(isValid, "\(failureMessage) got \(foundCommand.description) instead")
        }
        
        argument.getCommand().do(
            onFailure: { XCTFail("Input: None \($0.description)") },
            onSuccess: validateCommand)
    }
    
    func test_BranchParseCommand() {
        let userInputs = "eng"
        let args = CLITestUtil.makeBranchParseArgument(userInput: [userInputs])
        let argument = CLIArguments(arguments: args)
        let expectedCommand = UserCommand.modeBranchParse(validator: userInputs)
        let failureMessage = "Expected the input of -b \(userInputs) to return to return "
        + "an output of \(expectedCommand.description)"
        
        print("⚖️  ~ Testing -b \(userInputs) for command \(expectedCommand.description)")
        func validateCommand(foundCommand: UserCommand) -> Void {
            let isValid = UserCommand.isEquivelent(lhs: foundCommand, rhs: expectedCommand)
            XCTAssert(isValid, "\(failureMessage) got \(foundCommand.description) instead")
            let validatorsMatch = UserCommand.isValueEquivelent(
                lhs: foundCommand, rhs: expectedCommand)
            let foundValidator = foundCommand.associatedValue() ?? "Nil"
            XCTAssert(validatorsMatch, """
                Expected found branch validator \(foundValidator) to be \(userInputs)
                """)
        }
        
        argument.getCommand().do(
            onFailure: { XCTFail("Input: -b \(userInputs) \($0.description)") },
            onSuccess: validateCommand)
    }
    
    func test_ExtraArgsBranchParseCommand() {
        let userInputs = ["eng", "somethingExtra"]
        let badInputValue = userInputs.joined(separator: " ")
        let badArgs = CLITestUtil.makeBranchParseArgument(userInput: userInputs)
        let badArgument = CLIArguments(arguments: badArgs)
        let expectedCommand = UserCommand.modeBranchParse(validator: badInputValue)
        print("⚖️  ~ Testing invalid -b \(badInputValue) for command \(expectedCommand.description)")
        let badFailureMessage = "Expected the input of -b \(badInputValue) to fail "
        + "in outputting \(expectedCommand.description)"
        badArgument.getCommand().do { _ in XCTFail(badFailureMessage) }
    }
    
    static var allTests = [
        ("test_SingleArgumentShortCommands", test_SingleArgumentShortCommands),
        ("test_SingleArgumentLongCommands", test_SingleArgumentLongCommands),
        ("test_FailingSingleArgumentShortCommands", test_FailingSingleArgumentShortCommands),
        ("test_FailingSingleArgumentLongCommands", test_FailingSingleArgumentLongCommands),
        ("test_ExtraArgsSingleArgumentShortCommands", test_ExtraArgsSingleArgumentShortCommands),
        ("test_ExtraArgsSingleArgumentLongCommands", test_ExtraArgsSingleArgumentLongCommands),
        ("test_ViewStateCommand", test_ViewStateCommand),
        ("test_BranchParseCommand", test_BranchParseCommand),
        ("test_ExtraArgsBranchParseCommand", test_ExtraArgsBranchParseCommand)
    ]
    
}

typealias UserCommand = CLIArguments.UserCommand

typealias CLITestArgument = CLITestUtil.Argument

struct CLITestUtil {
    
    struct Argument {
        let short: String
        let long: String
        let expected: UserCommand
        
        struct SingleArgumentPair {
            let proper: Argument
            let malformed: Argument
            let extraInput: String
        }
        
        // Correctly Formed Arguments
        static let version = Self(short: "-v", long: "--version", expected: .outputVersion)
        static let output = Self(short: "-o", long: "--output", expected: .outputPrefixes)
        static let delete = Self(short: "-d", long: "--delete", expected: .deletePrefixes)
        static let normal = Self(short: "-n", long: "--normal", expected: .modeNormal)
        
        // Malformed Arguments
        static let badVersion = Self(short: "-cv", long: "--verzion", expected: .outputVersion)
        static let badOutput = Self(short: "-op", long: "--ouput", expected: .outputPrefixes)
        static let badDelete = Self(short: "-ds", long: "--dekete", expected: .deletePrefixes)
        static let badNormal = Self(short: "-nm", long: "--notmal", expected: .modeNormal)
        
        static let singleArgs: [SingleArgumentPair] = [
            .init(proper: .version, malformed: .badVersion, extraInput: "need me some version"),
            .init(proper: .output, malformed: .badOutput, extraInput: "show me the raw output"),
            .init(proper: .delete, malformed: .badDelete, extraInput: "delete this prefix"),
            .init(proper: .normal, malformed: .badNormal, extraInput: "get me to normal mode")
        ]
        
    }
    
    static func makeBranchParseArgument(
        useLong: Bool = false,
        userInput: [String]
    ) -> [String] {
        let argList = ["executable/location", (useLong ? "--branchParse" : "-b")]
        return argList + userInput
    }
    
    static func makeArgument(
        _ arg: Argument,
        useLong: Bool = false,
        userInput: String? = nil
    ) -> [String] {
        let argList = ["executable/location", (useLong ? arg.long : arg.short)]
        guard let userInput = userInput else { return argList }
        return argList + [userInput]
    }
    
    static func assertOnProperSingleArg(_ command: Argument, useLong: Bool = false) {
        let inputValue = useLong ? command.long : command.short
        print("⚖️  ~ Testing \(inputValue) for command \(command.expected.description)")
        let argument = CLIArguments(arguments: makeArgument(command, useLong: useLong))
        let failureMessage = """
        Expected the input of \(inputValue) to return an output of \(command.expected.description)
        """
        func validateCommand(foundCommand: UserCommand) -> Void {
            guard UserCommand.isEquivelent(lhs: foundCommand, rhs: command.expected) else {
                XCTFail(failureMessage)
                return
            }
        }
        argument.getCommand().do(
            onFailure: { XCTFail("Input: \(inputValue) " + $0.description) },
            onSuccess: validateCommand)
    }
    
    static func assertOnMalformedSingleArg(_ command: Argument, useLong: Bool = false) {
        let badInputValue = useLong ? command.long : command.short
        print("⚖️  ~ Testing invalid \(badInputValue) for command \(command.expected.description)")
        let badArgument = CLIArguments(arguments: makeArgument(command, useLong: useLong))
        let badFailureMessage = """
        Expected the input of \(badInputValue) to fail in outputting \(command.expected.description)
        """
        badArgument.getCommand().do { _ in XCTFail(badFailureMessage) }
    }
    
    static func assertOnExtraArgsForSingleArg(
        _ command: Argument,
        extraInput: String,
        useLong: Bool = false
    ) {
        let inputValue = useLong ? command.long : command.short
        let testingMessage = "⚖️  ~ Testing invalid extra args \(inputValue) \(extraInput)"
        + " for command \(command.expected.description)"
        print(testingMessage)
        let badArgument = CLIArguments(
            arguments: makeArgument(command, useLong: useLong, userInput: extraInput))
        let badFailureMessage = "Expected the input of \(inputValue) \(extraInput)"
        + "to fail in outputting \(command.expected.description)"
        badArgument.getCommand().do { _ in XCTFail(badFailureMessage) }
    }
    
}

extension CLIError {
    
    var description: String {
        switch self {
        case .commandNotRecognized:
            return "CLIError: Command Not Recognized"
        case .tooManyArguments:
            return "CLIError: Too Many Arguments"
        case .emptyEntry:
            return "CLIError: Empty Entry"
        case .invalidEntryFormat:
            return "CLIError: Invalid Entry Format"
        case .unexpectedError:
            return "CLIError: Unexpected Error"
        }
    }
    
}

extension UserCommand {
    
    var description: String {
        switch self {
        case .outputVersion:
            return "outputVersion"
        case .viewState:
            return "viewState"
        case .outputPrefixes:
            return "outputPrefixes"
        case .deletePrefixes:
            return "deletePrefixes"
        case .modeNormal:
            return "modeNormal"
        case let .modeBranchParse(validator):
            return "modeBranchParse \(validator)"
        case let .newPrefixes(value):
            return "newPrefixes \(value)"
        }
        
    }
    
    static func isEquivelent(lhs: UserCommand, rhs: UserCommand) -> Bool {
        switch (lhs, rhs) {
        case (.outputVersion, .outputVersion),
             (.viewState, .viewState),
             (.outputPrefixes, .outputPrefixes),
             (.deletePrefixes, .deletePrefixes),
             (.modeNormal, .modeNormal),
             (.modeBranchParse, .modeBranchParse),
             (.newPrefixes, .newPrefixes):
            return true
        default:
            return false
        }
        
    }
    
    static func isValueEquivelent(lhs: UserCommand, rhs: UserCommand) -> Bool {
        switch (lhs, rhs) {
        case let (.modeBranchParse(lhsValue), .modeBranchParse(rhsValue)):
              return lhsValue == rhsValue
        case let (.newPrefixes(lhsValue), .newPrefixes(rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
    
    func associatedValue() -> String? {
        switch self {
        case let .modeBranchParse(validator: value):
            return value
        case let .newPrefixes(value: value):
            return value
        default:
            return nil
        }
    }
}
