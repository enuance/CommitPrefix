# commitPrefix

## A command line utility that easily prefixes your commit messages.

___

### -- About --

CommitPrefix is a simple command line tool that helps you to easily prefix your commit messages. The common use case for this is tagging your commit messages with a Jira (or other issue tracking software) ticket number. The desired prefix is stored within the .git folder and picked up by a generated commit-message hook. This allows you to write your ticket number (or any other prefix) once. From then on all commit messages will be prepended with the saved prefix.

Prefixes can be re-assigned or deleted at any time. Additionally, this is a git repository specific tool, meaning that stored prefixes are specific to the repository you're in.

The actions that can be done are:

* Store a commit prefix
* Delete the currently stored prefix
* View the currently stored prefix

___
### -- Installation --

1. Clone the repo

```zsh
% git clone https://github.com/enuance/commitPrefix.git
```

2. Open the Package

```zsh
% cd commitPrefix
% open Package.swift
```

3. Build the executable by pressing **⌘B** or select it from the menu **Product -> Build**

4. Locate the executable by running this in the terminal

```zsh
% find ~/Library/Developer/Xcode/DerivedData -name "commitPrefix"
```

This command will display all locations where files have the name “commitPrefix”
It should be the one contained in `/Users/<UserName>/Library/Developer/Xcode/DerivedData/commitPrefix-<GeneratedString>/Build/Products/Release/commitPrefix`

Make sure not to select ones that have `commitPrefix.dSYM` in it's path

5. Open a window at the location by using Finder and selecting **Go -> Go to folder...** enter in the path and select **Go**

You can also use the terminal **open** command but you'd have to remove the executable `/commitPrefix` from the end of the path

6. Open your local executables folder by entering: 

```zsh
% open /usr/local/bin
```

7. Drag and drop the Unix executable `commitPrefix` into you `bin` folder. On your next Terminal session you should be able to see auto-completion and use commitPrefix.

___
### -- Usage --


To use commitPrefix you need to have your working directory set to one that has a git repository in it.
```zsh
% cd SomeGitRepository
```

To **store** a prefix
```zsh
% commitPrefix SamplePrefix-001

# Output
CommitPrefix saved: [SamplePrefix-001]
```

To **view** a prefix
```zsh
% commitPrefix --view

# Output
CommitPrefix: [SamplePrefix-001]
```

To **delete** a prefix
```zsh
% commitPrefix --delete

# Output
CommitPrefix Deleted
```

You can also view these command along with shortend version by using the `--help` tag.
