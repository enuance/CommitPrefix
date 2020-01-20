//
//  String+Extensions.swift
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

public extension String {
    
    private func findMatches(in string: String, using regex: String) -> [String] {
        
        #if DEBUG
        let isValid = (try? NSRegularExpression(pattern: regex, options: [])) != nil
        assert(isValid, "Invalid Regex Pattern: \(regex)")
        #endif
        
        var searchString = string
        var foundMatches = [String]()
        
        var nextMatchFound: Range<String.Index>? {
            searchString.range(of: regex, options: .regularExpression)
        }
        
        func newSearch(string: String, removing range: Range<String.Index>) -> String {
            var newString = string
            let removingRange = string.startIndex..<range.upperBound
            newString.removeSubrange(removingRange)
            return newString
        }
        
        while let matchRange = nextMatchFound {
            let newMatch = String(searchString[matchRange])
            foundMatches.append(newMatch)
            searchString = newSearch(string: searchString, removing: matchRange)
        }
        
        return foundMatches
    }
    
    func occurances(ofRegex pattern: String) -> [String] {
        findMatches(in: self, using: pattern)
    }
    
}
