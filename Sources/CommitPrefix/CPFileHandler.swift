//
//  CPFileHandler.swift
//
//
//  Created by Stephen Martinez on 12/3/19.
//

import Foundation
import Files

public struct CPFileHandler {
    
    private let commitPrefixFile: File
    private let commitMessageHook: CommitMessageHook
    
    public init() throws {
        let currentDirectory = Folder.current
        let correctLocation = currentDirectory.containsSubfolder(named: FolderName.git)
        guard correctLocation else {
            throw CPError.notAGitRepo(currentLocation: currentDirectory.path)
        }
        let gitDirectory = try currentDirectory.subfolder(named: FolderName.git)
        self.commitPrefixFile = try gitDirectory.createFileIfNeeded(withName: FileName.commitPrefix)
        self.commitMessageHook = try CommitMessageHook(gitDirectory: gitDirectory)
    }
    
    public func locateOrCreateHook() throws {
        try commitMessageHook.locateOrCreateHook()
    }
    
    public func outputPrefix() throws -> String {
        let contents = try? commitPrefixFile.readAsString(encodedAs: .utf8)
        guard let readContents = contents else {
            throw CPError.fileReadWriteError
        }
        return readContents
    }
    
    public func deletePrefix() throws -> String {
        do {
            try commitPrefixFile.write("", encoding: .utf8)
        } catch {
            throw CPError.fileReadWriteError
        }
        return "CommitPrefix Deleted"
    }
    
    public func writeNew(prefix: String) throws -> String {
        let bracketSet = CharacterSet(charactersIn: "[]")
        let debracketedPrefix = prefix.trimmingCharacters(in: bracketSet)
        let formattedPrefix = "[\(debracketedPrefix)]"
        do {
            try commitPrefixFile.write(formattedPrefix, encoding: .utf8)
        } catch {
            throw CPError.fileReadWriteError
        }
        return formattedPrefix
    }
    
}
