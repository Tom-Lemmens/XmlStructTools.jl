# The generated module takes its name from the prefix bound to the schema's targetNamespace, and
# from the namespace itself when the target namespace is the default one. Published ISO 20022
# schemas are the second shape: they declare `xmlns="urn:iso:...:pacs.008.001.09"` and prefix only
# the XML Schema namespace, so a rule that takes the first prefixed binding names the module `xs`
# and nothing in it can be found.

@testset "Namespace module name" begin
    @testset "Namespace module name - derived from a namespace" begin
        @test AbstractXsdTypes.namespace_module_name("urn:iso:std:iso:20022:tech:xsd:pacs.008.001.09") ===
            :pacs_008_001_09
        @test AbstractXsdTypes.namespace_module_name("http://example.com/schemas/Orders") === :Orders
        @test AbstractXsdTypes.namespace_module_name("urn:example:2024") === :_2024
        @test_throws ArgumentError AbstractXsdTypes.namespace_module_name("")
    end

    @testset "Namespace module name - prefix bound to the target namespace wins" begin
        # This schema declares xmlns:xsd (the schema language) before its own prefix.
        xsd_path = joinpath(specific_data_dir, "documentation_example.xsd")
        tree = XsdToStruct.read_xsd(xsd_path)
        @test XsdToStruct.name(tree) == "DocumentationExample"
    end

    @testset "Namespace module name - a default target namespace, as ISO 20022 publishes" begin
        xsd_path = joinpath(
            pkgdir(XsdToStruct), "test", "test_data", "real_world", "pacs.008.001.09.xsd",
        )
        tree = XsdToStruct.read_xsd(xsd_path)
        @test XsdToStruct.name(tree) == "pacs_008_001_09"
    end

    @testset "Namespace module name - a schema without a target namespace fails" begin
        mktempdir() do dir
            path = joinpath(dir, "no_target.xsd")
            write(
                path,
                """
                <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
                    <xs:element name="document" type="xs:string"/>
                </xs:schema>
                """,
            )
            @test_throws "targetNamespace" XsdToStruct.read_xsd(path)
        end
    end
end
