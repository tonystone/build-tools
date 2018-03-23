# Build Tools
## xctest_tool.rb
To run `swift test` on Linux, SPM requires that a runner is created that loads and executes the tests on this platform.  This script will generate the necessary files based on your `Package.swift` and test source.

##### Usage

```
xctest_tool.rb [--package-path path] [--header-template path] [--extension-files true|false]
```

If you omit the `--package-path` parameter, this script will use the current directory `./` to attempt to locate the `Package.swift` file.  To override this and run the script from any location, pass `--package-path` with the full directory containing the package manifest.

If the script finds a file named `.build-tools.header` in the `--package-path` directory, it will use that file as a header template for each generated file.  The name and location of the file can be overridden by passing the `--header-template` parameter with the name and path of the file to use.

> Note: If a file already has a header in place that was auto-generated, this script will use the existing header.

##### Generated files
When executed, this script will read all test targets in your package and parse the tests in each to produce class extensions describing the classes and methods contained in the file.  It follows the same convention as XCTest does in determining if a class/method is a part of the tests or not.  Once it processes all the test source files, it will produce a `LinuxMain.swift` file to execute each test in the suite. 

The script can either embed the extensions in the `LinuxMain.swift` file or create extension files for each source files it encounters.

For example given the following package structure:
<pre>
MyProject 
|--- Package.swift
|--- Sources
|    |--- MyFramework
|         |--- File.swift
|--- Tests
|    |--- MyFramework
|         |--- FileTests.swift
</pre>

Running `xctest_tool.rb --extension-files=false` will produce the following extra files.
<pre>
MyProject 
|--- Package.swift
|--- Sources
|    |--- MyFramework
|         |--- File.swift
|--- Tests
|    |--- <b>LinuxMain.swift</b>                <--- Adds a main for execution with extensions embeded in LinuxMain.swift
|    |
|    |--- MyFramework
|         |--- FileTests.swift
</pre>

Running `xctest_tool.rb --extension-files=true` will produce the following extra files.
<pre>
MyProject 
|--- Package.swift
|--- Sources
|    |--- MyFramework
|         |--- File.swift
|--- Tests
|    |--- <b>LinuxMain.swift</b>                <--- Adds a main for execution
|    |
|    |--- MyFramework
|         |--- FileTests.swift
|         |
|         |--- <b>FileTests+XCTest.swift</b>    <--- Adds an extension file per test file
</pre>
 > **Note:** These added files are ignored by the **macOS XCTest** runner.        
 
> **Note:** This script will not change your source files but will overwrite files with the name `LinuxMain.swift` and files matching your source with the name `<MyFileName>+XCTest.swift` if `--extension-files=true` is passed.

