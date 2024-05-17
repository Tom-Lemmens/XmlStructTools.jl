# XsdToStruct

This package generates a module with struct definitions which correspond to the data types specified in a given XML Schema file. Apart from the definitions it also generates constructors which can (partially) validate the data that is given with the restrictions specified in the schema file.

## Generating the Julia structs

In this example we create the struct definitions for the "documentation_example.xsd" schema file included in this package. It can be found in the "test/test_data/specific_cases" folder. We can generate the corresponding struct definitions by running the following code snippet:

```julia
using XsdToStruct

xsd_path = pkgdir(XsdToStruct, "test", "test_data", "specific_cases", "documentation_example.xsd")
xsd_to_struct_module(xsd_path)
```

This will create a new subfolder with the same name as the original XSD file, in this case "documentation_example", in the same location as the XSD file. In case a different output directory is required, you can provide this as the second argument. The newly created folder will contain a couple fo files but the important one has the same name as the XSD file but with the ".jl" extension, in this example this will be "documentation_example.jl". This file will contain the module that you need to include in order to use the generated structure definitions.

If you have multiple XSD files, these can be handled in a single call to `xsd_to_struct_module` like so:

```julia
using XsdToStruct

xsd_locations = Dict(
    "file_1" => joinpath("path", "to", "xsd_files", "file_1.xsd"),
    "file_2" => joinpath("path", "to", "xsd_files", "file_1.xsd"),
    "file_3" => joinpath("path", "to", "xsd_files", "file_1.xsd")
)
xsd_modules_path = joinpath("some", "output", "path")
generate_modules(xsd_locations, xsd_modules_path)
```

This will generate a subfolder for each XSD file in the given `xsd_modules_path` folder.
In this "batch" mode it is also possible to only specify a directory as location:

```julia
using XsdToStruct

xsd_file_directory = joinpath("path", "to", "xsd_files")
xsd_locations = Dict(
    "file_1" => xsd_file_directory,
    "file_2" => xsd_file_directory,
    "file_3" => xsd_file_directory,
    "some_other_file" => joinpath("path", "to", "some", "other", "xsd_file", "some_other_file.xsd")
)
xsd_modules_path = joinpath("some", "output", "path")
generate_modules(xsd_locations, xsd_modules_path)
```

In this case the function will look for a file with the given name and the ".xsd" extension in the given directory. Hence in this example it will generate modules for `joinpath("path", "to", "xsd_files", "file_1.xsd")`, `joinpath("path", "to", "xsd_files", "file_2.xsd")`, `joinpath("path", "to", "xsd_files", "file_3.xsd")`, and `joinpath("path", "to", "some", "other", "xsd_file", "some_other_file.xsd")`.

In "batch" mode it is also possible to specify a URL:

```julia
using XsdToStruct

xsd_file_directory = joinpath("path", "to", "xsd_files")
xsd_locations = Dict(
    "file_1" => xsd_file_directory,
    "file_2" => xsd_file_directory,
    "file_3" => xsd_file_directory,
    "some_other_file" => joinpath("path", "to", "some", "other", "xsd_file", "some_other_file.xsd"),
    "remote_file" => "https://url.to.some/xsd/file"
)
xsd_modules_path = joinpath("some", "output", "path")
generate_modules(xsd_locations, xsd_modules_path)
```

In this case it will download the file from the given URL and save the output under the name given by the key in the dict, in this case "remote_file".

## Using the generated structure definitions

If you want to use the generated structure definitions you only have to include the file in the newly created folder with the same name as the original XSD file except with a ".jl" extension. So for our "documentation_example.xsd" this will be "documentation_example.jl". The generated module will always depend on "AbstractXsdTypes" and "Reexport" so these packages need to be available where you want to use the structure definitions. Optionally "Dates" and "TimeZones" are also needed. The docstring of the generated module will list all the needed dependencies for that generated module.

The main module that is generated will have the same name as the target namespace of the given XSD file. This module will also export the generated types. Hence be careful when `using` these modules since they can inject many types that you might not expect into your code.

## What is generated

Apart from the main file with the main module there will also be one or more extra files in the generated folder, these can be ignored. These extra files are already included in the main module which reexports the needed definitions from the other files. You might notice some extra namespaces when querying types from the main module but these can be ignored since everything that is needed is present in the namespace of the main module.

The main module will also contain a submodule called `__meta` that contains some extra information that could be useful. Most importantly, it contains the type of the root element which is needed when handling XML files.

Apart form the main file these is also a second file which contains a submodule with the structure definitions which has the "_struct" suffix. Apart from the structure definitions there are also a few utility functions that are defined in here. Mainly these will be related to input validation and default values for the schema types. For more information on these see the `AbstractXsdTypes` documentation.

## Note on Dependencies

Each generated module depends a few extra packages, you will have to add those yourself to your environment.
All modules depend upon:

* AbstractXsdTypes.jl
* Reexport.jl

And some also depend on:

* Dates.jl
* TimeZones.jl

The docstring of the generated module will always say which extra packages are needed.

## Known limitations

The XSD specification is quite extensive and complex hence not everything is completely supported.
Here is a non-exhaustive list of unsupported XSD features:

* Some type restrictions
* redefine
* include
* import
* XSD files with no targetNamespace declared
