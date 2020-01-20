//
//  commitPrefixTests.swift
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

import CLInterface
import Foundation
import XCTest

final class commitPrefixTests: XCTestCase {
    
    func test_wholeApplication() throws {

        guard #available(macOS 10.15, *) else { return }

        let commitPrefixBinary = TestUtilities.urlOfExecutable(named: "commitPrefix")

        let process = Process()
        process.executableURL = commitPrefixBinary

        let pipe = Pipe()
        process.standardOutput = pipe

        let errorPipe = Pipe()
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let errorOutput = String(data: errorData, encoding: .utf8)

        let noOutput = output == nil || output == ""
        let validStdErrOutput = (errorOutput ?? "")
            .contains("Error: Not in a git repo or at the root of one")
        
        XCTAssert(noOutput, """
        commitPrefix should only return stderr output at this point. A full mock file \
        environment has not been set up yet.
        """)
        
        XCTAssert(validStdErrOutput, "A CPError.notAGitRepo should be thrown here")
    }

    static var allTests = [
        ("test_wholeApplication", test_wholeApplication)
    ]
    
}
