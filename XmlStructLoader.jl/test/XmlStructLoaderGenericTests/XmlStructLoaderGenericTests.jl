
# input data
if VERSION < v"1.7"
    generic_data_dir = joinpath(pkgdir(XmlStructLoader), "test", "test_data", "generic_cases")
else
    generic_data_dir = pkgdir(XmlStructLoader, "test", "test_data", "generic_cases")
end
generic_test_files = get_test_files(generic_data_dir)

# generate modules for testing
generate_modules(generic_data_dir)

# run tests
include("load_tests.jl")
include("check_tests.jl")
