using TestItemRunner

# TestItemRunner rather than ReTestItems: ReTestItems assigns `Test.TESTSET_PRINT_ENABLE[]` in its
# runner, and that binding is a `ScopedValue` from Julia 1.13 on, so the suite dies before any item
# runs. TestItemRunner also depends only on TestItems/Test/TOML/Pkg, which keeps this package
# loadable on the same Julia versions as the rest of the repo.
#
# Run one item by name with:
#   @run_package_tests filter = ti -> occursin("round-trip", ti.name)
@run_package_tests
