//
//  main.swift
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
import Foundation

let commandLineInterface = CLIArguments()
let cpInterface = CommitPrefix.interface()

do {
    
    switch try commandLineInterface.getCommand() {
        
    case .outputVersion:
        let versionOutput = cpInterface.outputVersion()
        Consler.output(versionOutput)
        
    case .viewState:
        let viewStateOutput = try cpInterface.viewState()
        Consler.output(viewStateOutput)
        
    case .outputPrefixes:
        let prefixesOutput = try cpInterface.outputPrefixes()
        Consler.output(prefixesOutput)
        
    case .deletePrefixes:
        let deletionOutput = try cpInterface.deletePrefixes()
        Consler.output(deletionOutput)
    
    case .modeNormal:
        let normalModeOutput = try cpInterface.activateNormalMode()
        Consler.output(normalModeOutput)
        
    case .modeBranchParse(validator: let rawValidatorValue):
        let branchModeOutput = try cpInterface.activateBranchMode(with: rawValidatorValue)
        Consler.output(branchModeOutput)
        
    case .newPrefixes(value: let rawPrefixValue):
        let newPrefixesOutput = try cpInterface.writeNew(prefixes: rawPrefixValue)
        Consler.output(newPrefixesOutput)
        
    }
    
} catch let prefixError as CPError {
    
    Consler.output(prefixError.message ,type: .error)
    exit(prefixError.status.value)
    
} catch {
    
    Consler.output(
        "Unexpected Error: ", error.localizedDescription,
        descriptors: [.boldRed, .normal],
        type: .error)
    
    exit(TerminationStatus.unexpectedError.value)
    
}
