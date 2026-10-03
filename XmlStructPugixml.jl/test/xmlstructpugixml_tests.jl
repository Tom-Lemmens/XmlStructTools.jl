@testitem "read a sample document" begin
    using XmlStructPugixml
    fixture = joinpath(@__DIR__, "test_data", "sample.xml")

    doc = parse_file(fixture)
    @test doc != C_NULL
    r = root(doc)
    @test r != C_NULL
    @test node_name(r) == "Sample:document"
    attrs = each_attribute(r)
    @test attrs["xmlns:xsi"] == "http://www.w3.org/2001/XMLSchema-instance"
    @test has_element_children(r)
    kids = element_children(r)
    @test length(kids) == 3
    free_doc(doc)
end

@testitem "parse_file on missing/malformed input returns C_NULL" begin
    using XmlStructPugixml
    @test parse_file(joinpath(@__DIR__, "does_not_exist.xml")) == C_NULL
end

@testitem "parse_buffer matches parse_file" begin
    using XmlStructPugixml
    fixture = joinpath(@__DIR__, "test_data", "sample.xml")

    doc = parse_buffer(read(fixture))
    @test doc != C_NULL
    @test node_name(root(doc)) == "Sample:document"
    free_doc(doc)

    @test parse_buffer(UInt8[]) == C_NULL
end

@testitem "write then read back round-trips" begin
    using XmlStructPugixml
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

@testitem "malformed and empty input fail without crashing" begin
    using XmlStructPugixml
    @test parse_buffer(b"<a><b></a>") == C_NULL      # mismatched tags
    @test parse_buffer(UInt8[]) == C_NULL            # empty
    @test parse_buffer(b"<?xml version=\"1.0\"?>") == C_NULL   # declaration only, no root

    # The shim dereferences the document handle, so a failed parse must not reach it: these
    # throw instead of segfaulting the process.
    @test_throws ArgumentError root(C_NULL)
    @test_throws ArgumentError doc_as_node(C_NULL)
    @test_throws ArgumentError save_file(C_NULL, tempname())
end

@testitem "text content: entities, CDATA, whitespace, first-text-child rule" begin
    using XmlStructPugixml
    # These are the semantics a consumer inherits by using this package, so they are pinned
    # rather than discovered later: pugixml decodes entities and CDATA, and `node_text` is
    # pugixml's `child_value()` — the FIRST text child, not the concatenation of all of them.
    doc = parse_buffer(codeunits("<a>x &amp; y &lt; z &#x4E2D;</a>"))
    try
        @test node_text(root(doc)) == "x & y < z 中"
    finally
        free_doc(doc)
    end

    doc = parse_buffer(codeunits("<a><![CDATA[<raw & stuff>]]></a>"))
    try
        @test node_text(root(doc)) == "<raw & stuff>"
    finally
        free_doc(doc)
    end

    doc = parse_buffer(codeunits("<a>foo<!--c-->bar</a>"))
    try
        @test node_text(root(doc)) == "foo"
    finally
        free_doc(doc)
    end

    doc = parse_buffer(codeunits("<a>  padded  </a>"))
    try
        @test node_text(root(doc)) == "  padded  "
    finally
        free_doc(doc)
    end
end

@testitem "write side escapes text and attributes" begin
    using XmlStructPugixml
    doc = new_doc()
    r = append_child_element(doc_as_node(doc), "Root")
    @test set_node_text(r, "a<b & \"c\" 日本")
    append_attribute(r, "q", "1<2&\"q\"")
    path = tempname() * ".xml"
    try
        @test save_file(doc, path)
        free_doc(doc)
        back = parse_file(path)
        try
            @test node_text(root(back)) == "a<b & \"c\" 日本"
            @test each_attribute(root(back))["q"] == "1<2&\"q\""
        finally
            free_doc(back)
        end
    finally
        rm(path, force = true)
    end
end
