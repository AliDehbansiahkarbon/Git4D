# Git4D

Git4D is a RAD Studio IDE plugin for Delphi and C++Builder that integrates common source-control actions directly into the editor, project manager, and Tools menu.

This repository starts with the IDE integration layer:

- a design-time package for RAD Studio
- a ToolsAPI wizard registered through `RegisterPackageWizard`
- a top-level `Git4D` IDE menu
- editor/project/tab popup menu injection where RAD Studio exposes VCL popup menus
- repository discovery from the active module or active project
- settings persistence under the user's home profile in `Git4D\Git4D.ini`
- command launchers for common Git workflows and external clients

Supported external clients:

- Git command line
- TortoiseGit
- TortoiseSVN
- Git Extensions

The first milestone intentionally uses the Git command line as the backend. This keeps the IDE package small and stable while the richer commit graph, diff viewer, staging UI, provider integrations, and Options tree pages are added incrementally.

## Layout

- `Packages/Git4DRAD.dpk` - RAD Studio design-time package
- `Source/Git4D.Register.pas` - package registration entrypoint
- `Source/Git4D.Wizard.pas` - IDE menu/context-menu integration
- `Source/Git4D.Repository.pas` - repository and active-file discovery
- `Source/Git4D.Git.pas` - Git command launch helpers
- `Source/Git4D.GitExtensions.pas` - Git Extensions launcher integration
- `Source/Git4D.TortoiseGit.pas` - TortoiseGit launcher integration
- `Source/Git4D.TortoiseSVN.pas` - TortoiseSVN launcher integration
- `Source/Git4D.Settings.pas` - persisted settings
- `Source/Git4D.Options.pas` - IDE Options page integration
- `Source/Git4D.Dialogs.pas` - fallback dialogs and About box

## Build

Open `Packages/Git4DRAD.dpk` in RAD Studio and build/install it as a design-time package.

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

## Notes

- The plugin has been exercised primarily against RAD Studio 12.x and 13.x.
- The editor popup integration is intentionally conservative because RAD Studio menu internals differ between IDE versions.

## Next Milestones

1. Replace terminal-based status/commit flows with dockable VCL tool windows.
2. Add internal diff viewer with Delphi/C++ syntax-aware file labels.
3. Add commit graph model and repository browser.
4. Add a real `Tools > Options > Version Control > Git4D` page using the RAD Studio options service for each supported IDE version.
5. Add provider integrations for GitHub, GitLab, Azure DevOps, and Bitbucket Server.

<hr>
<p align="center">
<img src="https://i0.wp.com/blogs.embarcadero.com/wp-content/uploads/2022/11/dlogonew-5582740.png?resize=254%2C242&ssl=1" alt="Delphi">
</p>
<h5 align="center">
Made with :heart: on Delphi
</h5>
