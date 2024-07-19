var documenterSearchIndex = {"docs":
[{"location":"#XsdToStruct","page":"Home","title":"XsdToStruct","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package generates a module with struct definitions which correspond to the data types specified in a given XML Schema file. Apart from the definitions it also generates constructors which can (partially) validate the data that is given with the restrictions specified in the schema file.","category":"page"},{"location":"#Generating-the-Julia-structs","page":"Home","title":"Generating the Julia structs","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"In this example we create the struct definitions for the \"documentationexample.xsd\" schema file included in this package. It can be found in the \"test/testdata/specific_cases\" folder. We can generate the corresponding struct definitions by running the following code snippet:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using XsdToStruct\n\nxsd_path = pkgdir(XsdToStruct, \"test\", \"test_data\", \"specific_cases\", \"documentation_example.xsd\")\nxsd_to_struct_module(xsd_path)","category":"page"},{"location":"","page":"Home","title":"Home","text":"This will create a new subfolder with the same name as the original XSD file, in this case \"documentationexample\", in the same location as the XSD file. In case a different output directory is required, you can provide this as the second argument. The newly created folder will contain a couple fo files but the important one has the same name as the XSD file but with the \".jl\" extension, in this example this will be \"documentationexample.jl\". This file will contain the module that you need to include in order to use the generated structure definitions.","category":"page"},{"location":"","page":"Home","title":"Home","text":"If you have multiple XSD files, these can be handled in a single call to xsd_to_struct_module like so:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using XsdToStruct\n\nxsd_locations = Dict(\n    \"file_1\" => joinpath(\"path\", \"to\", \"xsd_files\", \"file_1.xsd\"),\n    \"file_2\" => joinpath(\"path\", \"to\", \"xsd_files\", \"file_1.xsd\"),\n    \"file_3\" => joinpath(\"path\", \"to\", \"xsd_files\", \"file_1.xsd\")\n)\nxsd_modules_path = joinpath(\"some\", \"output\", \"path\")\ngenerate_modules(xsd_locations, xsd_modules_path)","category":"page"},{"location":"","page":"Home","title":"Home","text":"This will generate a subfolder for each XSD file in the given xsd_modules_path folder. In this \"batch\" mode it is also possible to only specify a directory as location:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using XsdToStruct\n\nxsd_file_directory = joinpath(\"path\", \"to\", \"xsd_files\")\nxsd_locations = Dict(\n    \"file_1\" => xsd_file_directory,\n    \"file_2\" => xsd_file_directory,\n    \"file_3\" => xsd_file_directory,\n    \"some_other_file\" => joinpath(\"path\", \"to\", \"some\", \"other\", \"xsd_file\", \"some_other_file.xsd\")\n)\nxsd_modules_path = joinpath(\"some\", \"output\", \"path\")\ngenerate_modules(xsd_locations, xsd_modules_path)","category":"page"},{"location":"","page":"Home","title":"Home","text":"In this case the function will look for a file with the given name and the \".xsd\" extension in the given directory. Hence in this example it will generate modules for joinpath(\"path\", \"to\", \"xsd_files\", \"file_1.xsd\"), joinpath(\"path\", \"to\", \"xsd_files\", \"file_2.xsd\"), joinpath(\"path\", \"to\", \"xsd_files\", \"file_3.xsd\"), and joinpath(\"path\", \"to\", \"some\", \"other\", \"xsd_file\", \"some_other_file.xsd\").","category":"page"},{"location":"","page":"Home","title":"Home","text":"In \"batch\" mode it is also possible to specify a URL:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using XsdToStruct\n\nxsd_file_directory = joinpath(\"path\", \"to\", \"xsd_files\")\nxsd_locations = Dict(\n    \"file_1\" => xsd_file_directory,\n    \"file_2\" => xsd_file_directory,\n    \"file_3\" => xsd_file_directory,\n    \"some_other_file\" => joinpath(\"path\", \"to\", \"some\", \"other\", \"xsd_file\", \"some_other_file.xsd\"),\n    \"remote_file\" => \"https://url.to.some/xsd/file\"\n)\nxsd_modules_path = joinpath(\"some\", \"output\", \"path\")\ngenerate_modules(xsd_locations, xsd_modules_path)","category":"page"},{"location":"","page":"Home","title":"Home","text":"In this case it will download the file from the given URL and save the output under the name given by the key in the dict, in this case \"remote_file\".","category":"page"},{"location":"#Using-the-generated-structure-definitions","page":"Home","title":"Using the generated structure definitions","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"If you want to use the generated structure definitions you only have to include the file in the newly created folder with the same name as the original XSD file except with a \".jl\" extension. So for our \"documentationexample.xsd\" this will be \"documentationexample.jl\". The generated module will always depend on \"AbstractXsdTypes\" and \"Reexport\" so these packages need to be available where you want to use the structure definitions. Optionally \"Dates\" and \"TimeZones\" are also needed. The docstring of the generated module will list all the needed dependencies for that generated module.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The main module that is generated will have the same name as the target namespace of the given XSD file. This module will also export the generated types. Hence be careful when using these modules since they can inject many types that you might not expect into your code.","category":"page"},{"location":"#What-is-generated","page":"Home","title":"What is generated","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Apart from the main file with the main module there will also be one or more extra files in the generated folder, these can be ignored. These extra files are already included in the main module which reexports the needed definitions from the other files. You might notice some extra namespaces when querying types from the main module but these can be ignored since everything that is needed is present in the namespace of the main module.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The main module will also contain a submodule called __meta that contains some extra information that could be useful. Most importantly, it contains the type of the root element which is needed when handling XML files.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Apart form the main file these is also a second file which contains a submodule with the structure definitions which has the \"_struct\" suffix. Apart from the structure definitions there are also a few utility functions that are defined in here. Mainly these will be related to input validation and default values for the schema types. For more information on these see the AbstractXsdTypes documentation.","category":"page"},{"location":"#Note-on-Dependencies","page":"Home","title":"Note on Dependencies","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Each generated module depends a few extra packages, you will have to add those yourself to your environment. All modules depend upon:","category":"page"},{"location":"","page":"Home","title":"Home","text":"AbstractXsdTypes.jl\nReexport.jl","category":"page"},{"location":"","page":"Home","title":"Home","text":"And some also depend on:","category":"page"},{"location":"","page":"Home","title":"Home","text":"Dates.jl\nTimeZones.jl","category":"page"},{"location":"","page":"Home","title":"Home","text":"The docstring of the generated module will always say which extra packages are needed.","category":"page"},{"location":"#Known-limitations","page":"Home","title":"Known limitations","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The XSD specification is quite extensive and complex hence not everything is completely supported. Here is a non-exhaustive list of unsupported XSD features:","category":"page"},{"location":"","page":"Home","title":"Home","text":"Some type restrictions\nredefine\ninclude\nimport\nXSD files with no targetNamespace declared","category":"page"},{"location":"docstrings/","page":"Docstrings","title":"Docstrings","text":"Modules = [XsdToStruct]","category":"page"},{"location":"docstrings/#XsdToStruct.generate_modules-Tuple{Dict{<:AbstractString, <:AbstractString}, AbstractString}","page":"Docstrings","title":"XsdToStruct.generate_modules","text":"generate_modules(xsd_locations::Dict{AbstractString, AbstractString}, xsd_modules_path::AbstractString)::Nothing\n\nGenerate modules from the given locations. The xsd_locations should be a dict which maps xsd names to their locations. The location can either be a path to a file, or a directory where the xsd file is located, or a URL where the xsd file can downloaded from. The generated modules are placed into the given xsd_modules_path. It is recomended for any packages that use generated modules to use this function in a build script to generate up to date modules on the fly.\n\nExamples\n\nLet's assume we have a folder \"xsdfiles\" which contains the xsd files: \"file1.xsd\", \"file2.xsd\", and \"file3.xsd\", and we also have a file located at a URL. We can then generate modules for them and place these modules into the folder \"xsd_modules\" as follows:\n\njulia> using XsdToStruct\njulia> xsd_locations = Dict(\n    \"local_file_1\" => joinpath(\"path\", \"to\", \"xsd_files\", \"file_1.xsd\"),\n    \"local_file_2\" => joinpath(\"path\", \"to\", \"xsd_files\"),\n    \"local_file_3\" => joinpath(\"path\", \"to\", \"xsd_files\"),\n    \"remote_file\" => \"https://url.to.last/xsd/file\"\n)\njulia> xsd_modules_path = joinpath(\"output\", \"path\", \"for\", \"xsd\", \"modules\")\njulia> generate_modules(xsd_locations, xsd_modules_path)\n\n\n\n\n\n","category":"method"},{"location":"docstrings/#XsdToStruct.get_field_indices_of_type-Union{Tuple{T}, Tuple{Union{XsdToStruct.ComplexTreeNode, XsdToStruct.SchemaTreeNode}, Type{T}}} where T<:XsdToStruct.AbstractFieldData","page":"Docstrings","title":"XsdToStruct.get_field_indices_of_type","text":"get_field_indices_of_type(\n    node::Union{ComplexTreeNode, SchemaTreeNode},\n    ::Type{T}\n) where T <: AbstractFieldData\n\nFind indices for all elements in the fields attribute of the given node which are of the given FieldData type. Note that this does not include the child fields in the case of a ComplexTreeNode.\n\n\n\n\n\n","category":"method"},{"location":"docstrings/#XsdToStruct.parse_xsd_element_child-Tuple{LightXML.XMLElement, AbstractString}","page":"Docstrings","title":"XsdToStruct.parse_xsd_element_child","text":"parse_xsd_element_child(\n    xsd_element::XMLElement,\n    parent_name::AbstractString\n)::Tuple{FieldData, AbstractTreeNode}\n\nExtract child node from xsd element with a type defined inside the element\n\n\n\n\n\n","category":"method"},{"location":"docstrings/#XsdToStruct.qualified_type-Tuple{Union{XsdToStruct.ChoiceFieldData, XsdToStruct.FieldData}, AbstractString}","page":"Docstrings","title":"XsdToStruct.qualified_type","text":"qualified_type(\n    field_data::Union{FieldData, ChoiceFieldData},\n    xsd_namespace::AbstractString\n)::String\n\nReturn the qualified type name for the given field_data relative to the namespace defined by the xsd. Hence if any leading xsd namespace part is present in the qualified type name it will be removed.\n\n\n\n\n\n","category":"method"},{"location":"docstrings/#XsdToStruct.qualified_type-Tuple{Union{XsdToStruct.ChoiceFieldData, XsdToStruct.FieldData}}","page":"Docstrings","title":"XsdToStruct.qualified_type","text":"qualified_type(\n    field_data::Union{FieldData, ChoiceFieldData}\n)::String\n\nReturn the qualified type name for the given field_data as read from the xsd. This will include the xsd namespace explicitly if it was given in the xsd. If the qualified name relative to the xsd namespace is needed add the xsd namespace as a string as the second argument.\n\n\n\n\n\n","category":"method"},{"location":"docstrings/#XsdToStruct.qualified_type-Tuple{XsdToStruct.GroupFieldData}","page":"Docstrings","title":"XsdToStruct.qualified_type","text":"qualified_type(field_data::GroupFieldData)::String\n\nAn Xsd group does not really have a qualified name, hence just the name is returned\n\n\n\n\n\n","category":"method"},{"location":"docstrings/#XsdToStruct.required_julia_types-Tuple{XsdToStruct.ComplexTreeNode}","page":"Docstrings","title":"XsdToStruct.required_julia_types","text":"required_julia_types(complex_node::ComplexTreeNode)::Vector{String}\n\nReturns types which need to be defined in order for the struct definition of 'complex_node' to be valid.\n\n\n\n\n\n","category":"method"},{"location":"docstrings/#XsdToStruct.xsd_to_struct_module-Tuple{AbstractString, AbstractString}","page":"Docstrings","title":"XsdToStruct.xsd_to_struct_module","text":"xsd_to_struct_module(xsd_path::AbstractString, output_dir::AbstractString)::String\n\nGenerate Julia module corresponding to the given xsd file. The resulting Julia module will be placed in the given output_dir. The module generated will have the same name as the xsd namespace defined in the given xsd file. The path to the file with the generated code is given as a return value. The file generated will have the approximately the same name as the given xsd file but with a \".jl\" extension instead of \".xsd\". To use the generated module include the generated file that is returned by this function, and then use or import the module.\n\nExamples\n\njulia> using XsdToStruct\njulia> xsd_to_struct_module(joinpath(\"path\", \"to\", \"file.xsd\"), joinpath(\"output\", \"dir\"))\njulia> include(joinpath(\"output\", \"dir\", \"file\", \"file.jl\"))\njulia> using file_xsd_namespace\n\nor\n\njulia> using XsdToStruct\njulia> xsd_to_struct_module(joinpath(\"path\", \"to\", \"file.xsd\"), joinpath(\"output\", \"dir\"))\njulia> include(joinpath(\"output\", \"dir\", \"file\", \"file.jl\"))\njulia> import file_xsd_namespace\n\n\n\n\n\n","category":"method"},{"location":"docstrings/#XsdToStruct.xsd_to_struct_module-Tuple{AbstractString}","page":"Docstrings","title":"XsdToStruct.xsd_to_struct_module","text":"xsd_to_struct_module(xsd_path::AbstractString)::String\n\nGenerate Julia module corresponding to the given xsd file. The resulting Julia module will be placed in the same directory as the given xsd file. The path to the file with the generated code is given as a return value.\n\nExamples\n\njulia> using XsdToStruct\njulia> xsd_to_struct_module(joinpath(\"path\", \"to\", \"file.xsd\"))\njulia> include(joinpath(\"path\", \"to\", \"file\", \"file.jl\"))\njulia> using file_xsd_namespace\n\nor\n\njulia> using XsdToStruct\njulia> xsd_to_struct_module(joinpath(\"path\", \"to\", \"file.xsd\"))\njulia> include(joinpath(\"path\", \"to\", \"file\", \"file.jl\"))\njulia> import file_xsd_namespace\n\n\n\n\n\n","category":"method"}]
}