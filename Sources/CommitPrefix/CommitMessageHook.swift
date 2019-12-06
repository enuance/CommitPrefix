//
//  CommitMessageHook.swift
//  
//
//  Created by Stephen Martinez on 12/5/19.
//

import Foundation

fileprivate var currentDate: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    return formatter.string(from: Date())
}

public var commitPrefixIdentifier: String {
    return "Created by CommitPrefix"
}

public var commitMessageHook: String { """
    #!/bin/sh
    #
    # Commit-msg
    #
    # \(commitPrefixIdentifier) on \(currentDate)
    #
    
    # Get the current directory and store it
    currentDirectory=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
    
    # Locate the Commit Prefix file and read/store its contents
    prefix=$( echo $( cat $currentDirectory/../commitPrefix.txt ) )
    
    # Read and store the contents of the original commit message
    message=$( echo $( cat $1 ) )
    
    # Build the prepended message and overwrite the commit message
    echo "$( echo $prefix ) $( echo $message )" > $1
    """
}
