# Deferred loading must agree with eager loading value for value, so most of these compare the two
# directly rather than asserting expected values a second time.

@testset "Lazy document" begin
    list_module = joinpath(generic_data_dir, "list_content")
    list_xml = joinpath(generic_data_dir, "list_content.xml")
    basic_module = joinpath(generic_data_dir, "basic_types")
    basic_xml = joinpath(generic_data_dir, "basic_types.xml")

    @testset "Lazy document - fields match an eager load" begin
        module_ref = XmlStructLoader.import_module_from_xml(list_xml, list_module)
        eager = load(list_xml, module_ref)
        doc = lazyload(list_xml, module_ref)

        @test Set(propertynames(doc)) ⊆ Set(propertynames(eager))

        for field in propertynames(doc)
            lazy_value = getproperty(doc, field)
            eager_value = getproperty(eager, field)
            # A repeated field arrives as a LazyVector; comparing element by element is what
            # distinguishes "same values" from "same container".
            if lazy_value isa XmlStructLoader.LazyVector
                @test length(lazy_value) == length(eager_value)
                @test collect(lazy_value) == eager_value
            elseif lazy_value isa XmlStructLoader.LazyDocument
                @test string(materialize(lazy_value)) == string(eager_value)
            else
                @test string(lazy_value) == string(eager_value)
            end
        end
        close(doc)
    end

    @testset "Lazy document - materialize equals load" begin
        module_ref = XmlStructLoader.import_module_from_xml(list_xml, list_module)
        eager = load(list_xml, module_ref)
        doc = lazyload(list_xml, module_ref)
        # Rendered rather than compared with ==: the generated types define equality only for
        # numeric simple types, so two separately built objects are not `==` even when identical.
        @test string(materialize(doc)) == string(eager)
        # Kept, so a second call does not rebuild.
        @test materialize(doc) === materialize(doc)
        close(doc)
    end

    @testset "Lazy document - counting elements parses nothing" begin
        module_ref = XmlStructLoader.import_module_from_xml(list_xml, list_module)
        doc = lazyload(list_xml, module_ref)
        branch = doc.TestElement3
        @test branch isa XmlStructLoader.LazyDocument
        elements = branch.Element_type4_list
        @test elements isa XmlStructLoader.LazyVector
        @test length(elements) == 5
        @test occursin("0 read", string(elements))
        close(doc)
    end

    @testset "Lazy document - a vector element is parsed on access and kept" begin
        module_ref = XmlStructLoader.import_module_from_xml(list_xml, list_module)
        eager = load(list_xml, module_ref)
        doc = lazyload(list_xml, module_ref)
        elements = doc.TestElement1.Element_list_double
        @test elements isa AbstractVector
        @test elements[2] == eager.TestElement1.Element_list_double[2]
        # Same object on a second read, so callers can rely on identity for complex elements.
        complex_elements = doc.TestElement3.Element_type4_list
        @test complex_elements[1] === complex_elements[1]
        close(doc)
    end

    @testset "Lazy document - values survive closing the document" begin
        module_ref = XmlStructLoader.import_module_from_xml(basic_xml, basic_module)
        doc = lazyload(basic_xml, module_ref)
        first_field = first(propertynames(doc))
        kept = getproperty(doc, first_field)
        close(doc)
        # Parsed values hold no XML handle, so reading them after the close is defined behaviour.
        @test string(kept) != ""
        @test !isopen(doc)
    end

    @testset "Lazy document - reading a closed document throws" begin
        module_ref = XmlStructLoader.import_module_from_xml(list_xml, list_module)
        doc = lazyload(list_xml, module_ref)
        elements = doc.TestElement3.Element_type4_list
        close(doc)
        @test_throws "closed" collect(elements)
        @test_throws "closed" doc.TestElement1
        # Idempotent: closing twice is not an error.
        @test isnothing(close(doc))
    end

    @testset "Lazy document - the function form closes on exit" begin
        module_ref = XmlStructLoader.import_module_from_xml(list_xml, list_module)
        outside = lazyload(list_xml, module_ref) do doc
            @test isopen(doc)
            doc
        end
        @test !isopen(outside)
    end

    @testset "Lazy document - show does not parse the document" begin
        module_ref = XmlStructLoader.import_module_from_xml(list_xml, list_module)
        doc = lazyload(list_xml, module_ref)
        text = string(doc)
        @test occursin("LazyDocument", text)
        @test occursin("0 read", text)
        @test occursin("open", text)
        close(doc)
    end
end
