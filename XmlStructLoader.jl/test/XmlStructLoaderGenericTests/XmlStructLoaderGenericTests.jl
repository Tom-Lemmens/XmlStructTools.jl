
# input data
generic_data_dir = abspath(joinpath(pkgdir(XmlStructLoader), "test", "test_data", "generic_cases"))
generic_test_files = get_test_files(generic_data_dir)

# generate modules for testing
generate_modules(generic_data_dir)

# run tests
include("load_tests.jl")
include("check_tests.jl")
