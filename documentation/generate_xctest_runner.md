# Build Tools
## generate_xctest_runner.rb
To run `swift test` on linux, SPM requires that a runner is created that loads and executes the tests on this platform.  This script will generate the necessary files based on your `Package.swift` and test source.

##### Usage

```
generate_xctest_runner.rb [--package-path <path>] [--header-template <path>]
```

If you omit the `--package-path` parameter, this script will use the current directory `./` to attempt to locate the `Package.swift` file.  To override this and run the script from any location, pass `--package-path` with the full directory containing the package manifest.

If the script finds a file named `.build-tools.header` in the `--package-path` directory, it will use that file as a header template for each generated file.  The name and location of the file can be overridden by passing the `--header-template` parameter with the name and path of the file to use.

> Note: If a file already has a header in place that was auto-generated, this script will use the existing header.

##### Generated files
When executed, this script will read all test targets in your package and parse the tests in each to produce extension files for **XCTest** describing the classes and methods contained in the file.  It follows the same convention as XCTest does in determining if a class/method is a part of the tests or not.  Once it processes all the test source files, it will produce a `LinuxMain.swift` file to execute each test in the suite. 


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

Running `generate_xctest_runner.rb` will produce the following extra files.
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
 
 
> **Note:** this script will not change your original source files but will overwrite files with the name `LinuxMain.swift` and files matching your source with the name `<MyFileName>+XCTest.swift`.

> **Note:** These added files are ignored by the **macOS XCTest** runner.        