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

let cpCommandLineInterface = CLIArguments()

do {
    
    switch try cpCommandLineInterface.getCommand() {
        
    case .outputVersion:
        Consler.output(
            "CommitPrefix ", "version ", CPInfo.version,
            descriptors: [.normal, .cyan, .cyan])
        
    case .viewState:
        let fileHandler = try CPFileHandler()
        let viewStateOutput = try fileHandler.viewState()
        Consler.output(viewStateOutput)
        
    case .outputPrefixes:
        let fileHandler = try CPFileHandler()
        let prefixesOutput = try fileHandler.outputPrefixes()
        Consler.output(prefixesOutput)
        
    case .deletePrefixes:
        let fileHandler = try CPFileHandler()
        let deletionOutput = try fileHandler.deletePrefixes()
        Consler.output(deletionOutput)
    
    case .modeNormal:
        let fileHandler = try CPFileHandler()
        let normalModeOutput = try fileHandler.activateNormalMode()
        Consler.output(normalModeOutput)
        
    case .modeBranchParse(validator: let rawValidatorValue):
        let fileHandler = try CPFileHandler()
        let branchModeOutput = try fileHandler.activateBranchMode(with: rawValidatorValue)
        Consler.output(branchModeOutput)
        
    case .newPrefixes(value: let rawPrefixValue):
        let fileHandler = try CPFileHandler()
        let newPrefixesOutput = try fileHandler.writeNew(prefixes: rawPrefixValue)
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
