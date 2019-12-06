//
//  FileHandler.swift
//  
//
//  Created by Stephen Martinez on 12/3/19.
//

import Foundation
import Files

public struct FileHandler {
    
    private let gitDirectory: Folder
    private let commitPrefixFile: File
    
    public init() throws {
        let currentDirectory = Folder.current
        let correctLocation = currentDirectory.containsSubfolder(named: ".git")
        guard correctLocation else {
            throw CommitPrefixError.notAGitRepo(currentLocation: currentDirectory.path)
        }
        self.gitDirectory = try currentDirectory.subfolder(named: ".git")
        self.commitPrefixFile = try gitDirectory.createFileIfNeeded(withName: "CommitPrefix.txt")
    }
    
    private func getHooksDirectory() throws -> Folder {
        guard let hooksDirectory = try? gitDirectory.subfolder(named: "hooks") else {
            throw CommitPrefixError.directoryNotFound(name: "hooks", path: gitDirectory.path)
        }
        return hooksDirectory
    }
    
    private func getCommitHookFile() throws -> File? {
        
        let hooksDirectory = try getHooksDirectory()
        
        guard let foundCommitHookFile = try? hooksDirectory.file(named: "commit-msg") else {
        
            do {
                let commitHookFile = try hooksDirectory.createFile(named: "commit-msg")
                try commitHookFile.write(commitMessageHook, encoding: .utf8)
            } catch {
                throw CommitPrefixError.hookReadWriteError
            }
            
            return nil
            
        }
        
        return foundCommitHookFile
        
    }
    
    private func hookIsCommitPrefix(_ hookFile: File) throws -> Bool {
        
        guard let hookContents = try? hookFile.readAsString(encodedAs: .utf8) else {
            throw CommitPrefixError.hookReadWriteError
        }
        
        return hookContents.contains(commitPrefixIdentifier)
    }
    
    private func overwriteCommitHook(_ commitHookFile: File) throws {
        print("There seems to be an existing commit-msg found in the hooks directory")
        print("Would you like to overwrite? [y/n]")
        let answer = readLine() ?? ""
        
        switch answer {
            
        case "y":
            print("Overwritting existing commit-msg with generated hook")
            
            do {
                try commitHookFile.write(commitMessageHook, encoding: .utf8)
            } catch {
                throw CommitPrefixError.hookReadWriteError
            }
            
        case "n":
            print("Overwrite is cancelled")
            exit(0)
            
        default:
            
            throw CommitPrefixError.expectedYesOrNo
            
        }
    }
    
    public func locateOrCreateHook() throws {
        guard let foundCommitHookFile = try getCommitHookFile() else { return }
        guard try !hookIsCommitPrefix(foundCommitHookFile) else { return }
        try overwriteCommitHook(foundCommitHookFile)
    }
    
    public func outputPrefix() throws -> String {
        let contents = try? commitPrefixFile.readAsString(encodedAs: .utf8)
        guard let readContents = contents else {
            throw CommitPrefixError.fileReadWriteError
        }
        return readContents
    }
    
    public func deletePrefix() throws -> String {
        do {
            try commitPrefixFile.write("", encoding: .utf8)
        } catch {
            throw CommitPrefixError.fileReadWriteError
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
            throw CommitPrefixError.fileReadWriteError
        }
        return formattedPrefix
    }
    
}
