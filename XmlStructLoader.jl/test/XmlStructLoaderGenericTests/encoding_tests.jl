# pugixml decodes UTF-8, UTF-16 and UTF-32. A document declaring anything else is read as raw
# bytes, so non-ASCII text becomes an invalid `String` instead of failing: the declaration is
# checked so a caller hears about it.

@testset "Encoding declaration" begin
    @testset "Encoding declaration - a non-UTF declaration warns" begin
        @test_logs (:warn, r"UTF-8, UTF-16 and UTF-32") XmlStructLoader._warn_unsupported_encoding(
            """<?xml version="1.0" encoding="ISO-8859-1"?>""", "a document",
        )
    end

    @testset "Encoding declaration - UTF declarations and no declaration are silent" begin
        for declaration in (
            """<?xml version="1.0" encoding="UTF-8"?>""",
            """<?xml version="1.0" encoding="utf-16"?>""",
            """<?xml version="1.0"?>""",
            "<document/>",
        )
            @test isnothing(
                @test_logs min_level = Logging.Warn XmlStructLoader._warn_unsupported_encoding(
                    declaration, "a document",
                )
            )
        end
    end

    @testset "Encoding declaration - loading a UTF-8 document stays quiet" begin
        xml = joinpath(generic_data_dir, "basic_types.xml")
        module_dir = joinpath(generic_data_dir, "basic_types")
        module_ref = XmlStructLoader.import_module_from_xml(xml, module_dir)
        @test_logs min_level = Logging.Warn load(xml, module_ref)
    end
end
