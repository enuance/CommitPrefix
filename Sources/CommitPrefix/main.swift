
let commitPrefixCLI = CLIArguments()

do {
    
    let fileHandler = try FileHandler()
    
    try fileHandler.locateOrCreateHook()
    
    switch try commitPrefixCLI.getCommand() {
        
    case .delete:
        let deletedMessage = try fileHandler.deletePrefix()
        print(deletedMessage)
        
    case .view:
        let prefix = try fileHandler.outputPrefix()
        print("CommitPrefix: \(prefix)")
        
    case .newEntry(entry: let entry):
        let newPrefix = try fileHandler.writeNew(prefix: entry)
        print("CommitPrefix saved: \(newPrefix)")
        
    }
    
} catch let prefixError as CommitPrefixError {
    
    print(prefixError.message)
    
}
