
function get_simple_type(xsd_root::XMLElement, name::String)
    elts = get_elements_by_tagname(xsd_root, "simpleType")
    xsd_element = first(el for el in elts if attribute(el, "name") == name)
    return xsd_element
end

function get_simple_type_tree(xsd_root::XMLElement, name::String)
    xsd_element = get_simple_type(xsd_root, name)
    tree = XsdToStruct.parse_xsd_simple_type(xsd_element, name)
    return tree
end

@testset "XsdToStruct - XSD reader" begin
    @testset "XsdToStruct - XSD reader - SimpleTypes" begin
        xsd_path = joinpath(generic_data_dir, "simple_types.xsd")
        xsd_doc = parse_file(xsd_path)
        xsd_root = root(xsd_doc)

        name = "TestSimpleType1"
        tree = get_simple_type_tree(xsd_root, name)

        @test tree isa XsdToStruct.SimpleTreeNode
        @test tree.field.julia_type == "String"
        @test tree.restrictions isa AbstractDict{String,String}
        @test tree.restrictions["pattern"] == "([0-9A-Z]{4})?"
        @test tree.restrictions["maxLength"] == "4"
    end

    @testset "XsdToStruct - XSD reader - SimpleType Union" begin
        xsd_path = joinpath(generic_data_dir, "union_types.xsd")
        xsd_doc = parse_file(xsd_path)
        xsd_root = root(xsd_doc)

        # testing some internal functions work properly
        name = "TestDoubleRestrictedDouble"
        xsd_element = get_simple_type(xsd_root, name)
        @test XsdToStruct.is_union(xsd_element)
        tree = XsdToStruct.parse_xsd_simple_type(xsd_element, name)
        @test length(tree.union_nodes) == 2
        @test XsdToStruct.qualified_name(tree.union_nodes[1]) == "$(name)Types.type_1"
        @test XsdToStruct.qualified_name(tree.union_nodes[2]) == "$(name)Types.type_2"

        name = "UnionType"
        xsd_element = get_simple_type(xsd_root, name)
        @test XsdToStruct.is_union(xsd_element)
        tree = XsdToStruct.parse_xsd_simple_type(xsd_element, name)
        @test length(tree.union_nodes) == 2
        @test XsdToStruct.qualified_name(tree.union_nodes[1]) == "$(name)Types.type_1"
        @test XsdToStruct.qualified_name(tree.union_nodes[2]) == "$(name)Types.type_2"
    end

    @testset "XsdToStruct - XSD reader - Complex Type testing" begin
        xsd_path = joinpath(generic_data_dir, "complex_content.xsd")
        xsd_doc = parse_file(xsd_path)
        xsd_root = root(xsd_doc)

        elts = get_elements_by_tagname(xsd_root, "complexType")
        TestComplexType1 = elts[1]
        @test attribute(TestComplexType1, "name") == "TestComplexType1"
        TestComplexType2 = elts[2]

        sequence = collect(child_elements(TestComplexType1))[2]
        empty_element = last(collect(child_elements(sequence)))
        @test attribute(empty_element, "name") == "Element_empty"

        # this one errored in the past due to the empty element
        tree1 = XsdToStruct.parse_xsd_complex_type(TestComplexType1, "TestComplexType1")
        @test tree1 isa XsdToStruct.ComplexTreeNode
        first_child_field = first(tree1.child_fields)
        @test first_child_field.name == attribute(empty_element, "name")
        @test length(tree1.child_nodes) == 1
        empty_element_tree = tree1.child_nodes[1]
        @test empty_element_tree isa XsdToStruct.ComplexTreeNode
        @test isempty(empty_element_tree.fields)

        # second type is easier, it's just an extension of the first type
        tree2 = XsdToStruct.parse_xsd_complex_type(TestComplexType2, "TestComplexType2")
        @test tree2 isa XsdToStruct.ExtensionTreeNode
        @test tree2.base_name == "TestComplexType1"
    end
end
