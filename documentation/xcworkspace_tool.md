# Build Tools
## xcworkspace_tool.rb

**Xcworkspace Tool** allows you to create an Xcode Workspace that contains projects, playgrounds, groups and files programmatically.  

It can be used to create a workspaces to join projects and playgrounds allowing them to share modules and a build directory.

> Files with extension `.xcodeproj` and `.playground` will be added as a container, all other directories will be added as a `group` and files will be added as a file (`absolute`).

##### Usage

```bash
xcworkspace_tool workspace_name [*file_to_add]"

```

Options:
  * `workspace_name`   The name and optional path of the Workspace you'd like to create (Required)
  * `[*file_to_add]`   A list of files and directories to add to the workspace. (Projects, Playgrounds, directories, and ordinary files) 


##### Example

Running the following command will generate an Xcode Workspace named `GeoFeatures.xcworkspace` in the current directory which contains `GeoFeatures-Playground.playground` and `GeoFeatures.xcodeproj`.
```bash

# xcworkspace_tool GeoFeatures GeoFeatures-Playground.playground GeoFeatures.xcodeproj
```