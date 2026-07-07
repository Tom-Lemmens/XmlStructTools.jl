# Real-world stress fixture (see test_data/real_world/README.md): a genuine, unmodified ISO 20022
# schema and a real instance document (same field values as issettled/iso20022-issettled's own
# example, re-wrapped in the schema's actual Document root - see the README for why). Generated
# fresh into a tempdir rather than checked in, matching XsdToStruct.jl's own real-world test - the
# generated code for a schema this size isn't a golden fixture worth freezing byte-for-byte.
@testset "real world - pacs.008.001.09 loading" begin
    real_world_dir = joinpath(@__DIR__, "test_data", "real_world")
    xsd_path = joinpath(real_world_dir, "pacs.008.001.09.xsd")
    xml_path = joinpath(real_world_dir, "pacs.008.001.09_instance.xml")
    output_dir = mktempdir()

    generated_path = xsd_to_struct_module(xsd_path, output_dir)
    mod = Base.include(Main, generated_path)

    doc = Base.invokelatest(load, xml_path, mod)
    tx = Base.invokelatest(() -> doc.FIToFICstmrCdtTrf.CdtTrfTxInf[1])

    @test Base.invokelatest(() -> doc.FIToFICstmrCdtTrf.GrpHdr.MsgId) == "20220718USDDSA9153934686BLUEUSNY001"
    @test Base.invokelatest(() -> tx.IntrBkSttlmAmt) == 125000.0
    @test Base.invokelatest(() -> tx.Dbtr.Nm) == "COMPANY AAA INC"
    @test Base.invokelatest(() -> tx.Cdtr.Nm) == "COMPANY BBB INC"
    @test Base.invokelatest(() -> tx.IntrBkSttlmDt.value) == Date(2022, 7, 18)
    @test Base.invokelatest(() -> doc.FIToFICstmrCdtTrf.GrpHdr.CreDtTm.value) == DateTime(2022, 7, 18, 13, 22, 32)
end
