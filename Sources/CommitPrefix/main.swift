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

import Foundation

let cpCommandLineInterface = CLIArguments()

do {
    
    switch try cpCommandLineInterface.getCommand() {
        
    case .outputVersion:
        let version = CPInfo.version
        print("commitPrefix version \(version)")
        
    case .viewState:
        let fileHandler = try CPFileHandler()
        let currentState = try fileHandler.viewState()
        print(currentState)
        
    case .outputPrefixes:
        let fileHandler = try CPFileHandler()
        let prefixOutput = try fileHandler.outputPrefixes()
        print(prefixOutput)
        
    case .deletePrefixes:
        let fileHandler = try CPFileHandler()
        let deletionMessage = try fileHandler.deletePrefixes()
        print(deletionMessage)
    
    case .modeNormal:
        let fileHandler = try CPFileHandler()
        let modeSetMessage = try fileHandler.activateNormalMode()
        print(modeSetMessage)
        
    case .modeBranchParse(validator: let rawValidatorValue):
        let fileHandler = try CPFileHandler()
        let modeSetMessage = try fileHandler.activateBranchMode(with: rawValidatorValue)
        print(modeSetMessage)
        
    case .newPrefixes(value: let rawPrefixValue):
        let fileHandler = try CPFileHandler()
        let storedPrefixesMessage = try fileHandler.writeNew(prefixes: rawPrefixValue)
        print(storedPrefixesMessage)
        
    }
    
} catch let prefixError as CPError {
    
    print(prefixError.message)
    
} catch let terminationError as CPTermination {
    
    print(terminationError.message)
    exit(0)
    
} catch {
    
    print("Unexpected Error: ", error)
    exit(0)
    
}
