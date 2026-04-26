# Smart GitInsight

Smart GitInsight is a RAD Studio Git client/add-in for Delphi and C++Builder.

This repository starts with the IDE integration layer:

- a design-time package for RAD Studio
- a ToolsAPI wizard registered through `RegisterPackageWizard`
- a top-level `Smart GitInsight` IDE menu
- editor/project/tab popup menu injection where RAD Studio exposes VCL popup menus
- repository discovery from the active module or active project
- settings persistence under `%APPDATA%\Smart GitInsight`
- command launchers for common Git workflows

The first milestone intentionally uses the Git command line as the backend. This keeps the IDE package small and stable while the richer commit graph, diff viewer, staging UI, provider integrations, and Options tree pages are added incrementally.

## Layout

- `Packages/SmartGitInsightRAD.dpk` - RAD Studio design-time package
- `Source/SmartGitInsight.Register.pas` - package registration entrypoint
- `Source/SmartGitInsight.Wizard.pas` - IDE menu/context-menu integration
- `Source/SmartGitInsight.Repository.pas` - repository and active-file discovery
- `Source/SmartGitInsight.Git.pas` - Git command launch helpers
- `Source/SmartGitInsight.Settings.pas` - persisted settings
- `Source/SmartGitInsight.Dialogs.pas` - settings/about dialogs

## Build

Open `Packages/SmartGitInsightRAD.dpk` in RAD Studio and build/install it as a design-time package.

The package requires `designide`, so it is intended only for IDE installation, not runtime application use.

## Current Command Surface

Main menu:

- Browse Repository
- Status
- Commit
- Fetch
- Pull
- Push
- Stash
- Checkout Branch
- Create Branch
- Merge Branch
- Rebase Branch
- Cherry Pick
- Apply Patch
- Format Patch
- Manage Remotes
- Edit .gitignore
- Git Bash / Terminal
- Settings
- About

Context menus:

- Diff Current File
- File History
- Blame Current File
- Reset Current File Changes
- Stage Current File

## Next Milestones

1. Replace terminal-based status/commit flows with dockable VCL tool windows.
2. Add internal diff viewer with Delphi/C++ syntax-aware file labels.
3. Add commit graph model and repository browser.
4. Add a real `Tools > Options > Version Control > Smart GitInsight` page using the RAD Studio options service for each supported IDE version.
5. Add provider integrations for GitHub, GitLab, Azure DevOps, and Bitbucket Server.
