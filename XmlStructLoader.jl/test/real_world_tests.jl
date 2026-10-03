# A genuine, unmodified ISO 20022 schema and instance (provenance and license in XsdToStruct's
# test_data/real_world/README.md). This is the only test that takes a published schema from
# generation through to values: it exercises the generated date and date-time types, the
# namespace-derived module name, and a document whose root carries no prefix.
#
# The module is generated into a temporary directory rather than committed, because generated code
# for a schema this size is not a fixture worth freezing byte for byte. It is loaded through
# `import_module_from_xml` rather than included directly, so it lands where the packages it uses
# are reachable - and so the test exercises the entry point a caller would.

@testset "Real world" begin
    real_world_dir = pkgdir(XsdToStruct, "test", "test_data", "real_world")
    xsd_path = joinpath(real_world_dir, "pacs.008.001.09.xsd")
    xml_path = joinpath(real_world_dir, "pacs.008.001.09_instance.xml")

    @testset "Real world - pacs.008.001.09 loads with its values" begin
        output_dir = mktempdir()
        generated_path = xsd_to_struct_module(xsd_path, output_dir)
        mod = XmlStructLoader.import_module_from_xml(xml_path, dirname(generated_path))

        doc = Base.invokelatest(load, xml_path, mod)
        header = Base.invokelatest(() -> doc.FIToFICstmrCdtTrf.GrpHdr)
        tx = Base.invokelatest(() -> doc.FIToFICstmrCdtTrf.CdtTrfTxInf[1])

        @test Base.invokelatest(() -> header.MsgId) == "20220718USDDSA9153934686BLUEUSNY001"
        @test Base.invokelatest(() -> header.CreDtTm.value) == DateTime(2022, 7, 18, 13, 22, 32)
        @test Base.invokelatest(() -> tx.IntrBkSttlmAmt) == 125000.0
        @test Base.invokelatest(() -> tx.Dbtr.Nm) == "COMPANY AAA INC"
        @test Base.invokelatest(() -> tx.Cdtr.Nm) == "COMPANY BBB INC"
        # A generated simple type over `xs:date`: the loader has to parse a `Date` and keep the
        # wrapper rather than treating the type as one it did not generate.
        @test Base.invokelatest(() -> tx.IntrBkSttlmDt.value) == Date(2022, 7, 18)
    end

    @testset "Real world - a direct base64Binary field carries bytes" begin
        dir = mktempdir()
        write(joinpath(dir, "binary_field.xsd"), """
        <?xml version="1.0"?>
        <schema xmlns="http://www.w3.org/2001/XMLSchema" xmlns:BinaryField="BinaryField" targetNamespace="BinaryField">
            <element name="document" type="BinaryField:documentType"/>
            <complexType name="documentType">
                <sequence>
                    <element name="Payload" type="base64Binary"/>
                </sequence>
            </complexType>
        </schema>
        """)
        write(joinpath(dir, "binary_field.xml"), """
        <?xml version="1.0"?>
        <BinaryField:document xmlns:BinaryField="BinaryField">
            <Payload>aGVsbG8gSVNPIDIwMDIy</Payload>
        </BinaryField:document>
        """)
        generated_path = xsd_to_struct_module(joinpath(dir, "binary_field.xsd"), dir)
        mod = XmlStructLoader.import_module_from_xml(joinpath(dir, "binary_field.xml"), dirname(generated_path))
        doc = Base.invokelatest(load, joinpath(dir, "binary_field.xml"), mod)

        # The field holds the decoded bytes, not the base64 text and not one element per byte.
        @test Base.invokelatest(() -> doc.Payload) == Vector{UInt8}("hello ISO 20022")
    end
end
