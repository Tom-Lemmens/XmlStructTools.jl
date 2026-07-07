@testitem "read basic_types.xml" begin
    fixture = joinpath(@__DIR__, "..", "..", "XmlStructLoader.jl", "test", "test_data", "generic_cases", "basic_types.xml")

    doc = parse_file(fixture)
    @test doc != C_NULL
    r = root(doc)
    @test r != C_NULL
    @test node_name(r) == "TestComplexAndSimple:document"
    attrs = each_attribute(r)
    @test attrs["xmlns:xsi"] == "http://www.w3.org/2001/XMLSchema-instance"
    @test has_element_children(r)
    kids = element_children(r)
    @test length(kids) == 3
    free_doc(doc)
end

@testitem "parse_file on missing/malformed input returns C_NULL" begin
    @test parse_file(joinpath(@__DIR__, "does_not_exist.xml")) == C_NULL
end

@testitem "parse_buffer matches parse_file" begin
    fixture = joinpath(@__DIR__, "..", "..", "XmlStructLoader.jl", "test", "test_data", "generic_cases", "basic_types.xml")

    doc = parse_buffer(read(fixture))
    @test doc != C_NULL
    @test node_name(root(doc)) == "TestComplexAndSimple:document"
    free_doc(doc)

    @test parse_buffer(UInt8[]) == C_NULL
end

@testitem "write then read back round-trips" begin
    doc = new_doc()
    n = doc_as_node(doc)
    r = append_child_element(n, "TestRoot")
    @test r != C_NULL
    append_attribute(r, "xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
    child = append_child_element(r, "Leaf")
    @test set_node_text(child, "hello world")
    append_attribute(child, "id", "42")

    path = tempname() * ".xml"
    try
        @test save_file(doc, path)
        free_doc(doc)

        rdoc = parse_file(path)
        rr = root(rdoc)
        @test node_name(rr) == "TestRoot"
        @test each_attribute(rr)["xmlns:xsi"] == "http://www.w3.org/2001/XMLSchema-instance"
        rc = first_child_element(rr)
        @test node_name(rc) == "Leaf"
        @test node_text(rc) == "hello world"
        @test each_attribute(rc)["id"] == "42"
        free_doc(rdoc)
    finally
        rm(path; force = true)
    end
end
