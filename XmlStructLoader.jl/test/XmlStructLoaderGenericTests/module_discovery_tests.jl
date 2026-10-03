# The module a document loads into is the one its generated file defines. A document is free to
# bind the schema's namespace to any prefix, or to the default `xmlns`, so deriving the module's
# name from the document agrees with the generator only by coincidence.

@testset "Module discovery" begin
    module_dir = joinpath(generic_data_dir, "choice_element")
    xml = joinpath(generic_data_dir, "choice_element_1.xml")

    @testset "Module discovery - read from the generated file" begin
        module_file = XmlStructLoader.get_module_file_path(module_dir)
        @test XmlStructLoader.module_symbol_in_file(module_file) === :TestChoice
    end

    @testset "Module discovery - the file's docstring is not mistaken for the declaration" begin
        mktempdir() do dir
            path = joinpath(dir, "sample.jl")
            write(path, """
            \"\"\"
                module NotTheModule

            A docstring that names a module.
            \"\"\"
            module TheRealModule
            end
            """)
            @test XmlStructLoader.module_symbol_in_file(path) === :TheRealModule
        end
    end

    @testset "Module discovery - a file without a module fails" begin
        mktempdir() do dir
            path = joinpath(dir, "empty.jl")
            write(path, "# nothing here\n")
            @test_throws "no module declaration" XmlStructLoader.module_symbol_in_file(path)
        end
    end

    @testset "Module discovery - a document choosing its own prefix still loads" begin
        mktempdir() do dir
            # Same document, bound to a prefix of the author's choosing rather than the schema's.
            rewritten = replace(read(xml, String), "TestChoice:" => "Whatever:", "xmlns:TestChoice" => "xmlns:Whatever")
            path = joinpath(dir, "choice_element_1.xml")
            write(path, rewritten)
            loaded = load(path, module_dir)
            @test !isnothing(loaded)
        end
    end
end
