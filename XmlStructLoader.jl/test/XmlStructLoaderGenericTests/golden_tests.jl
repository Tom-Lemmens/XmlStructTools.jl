# Golden tests: load every generic fixture and compare a full rendering of the loaded object
# against a committed file. Where the other tests assert that a load does not throw, these pin
# what it produced - field by field, including vector order and length, attributes, defaults and
# choice placement.
#
# The renderer below is deliberately local rather than `show`/`print_tree`: a golden is only
# useful if it changes when the loaded data changes and at no other time, so it must not move
# when unrelated display code does. Dict keys are sorted because attribute order is not
# meaningful.
#
# Regenerate after an INTENDED behaviour change, never to make a failure go away:
#   REGEN_GOLDENS=1 julia --project=XmlStructLoader.jl -e 'import Pkg; Pkg.test()'

const GOLDEN_DIR = joinpath(generic_data_dir, "..", "goldens")

_is_leaf(x) = x === nothing || x isa AbstractString || x isa Number || x isa Symbol ||
    x isa Bool || x isa Type || !isstructtype(typeof(x))

function render(io::IO, x, indent::Int = 0)
    pad = "  "^indent
    if x isa AbstractDict
        if isempty(x)
            println(io, pad, "(no attributes)")
        else
            for k in sort(collect(keys(x)); by = string)
                println(io, pad, repr(k), " => ", repr(x[k]))
            end
        end
    elseif x isa AbstractVector
        println(io, pad, "Vector of ", length(x), " (", eltype(x), ")")
        for (i, el) in enumerate(x)
            println(io, pad, "  [", i, "]")
            render(io, el, indent + 2)
        end
    elseif x isa NamedTuple
        if isempty(x)
            println(io, pad, "(empty NamedTuple)")
        else
            for k in keys(x)
                println(io, pad, k, ":")
                render(io, getfield(x, k), indent + 1)
            end
        end
    elseif _is_leaf(x)
        println(io, pad, repr(x))
    else
        T = typeof(x)
        println(io, pad, nameof(T))
        for f in fieldnames(T)
            println(io, pad, "  ", f, ":")
            render(io, getfield(x, f), indent + 2)
        end
    end
    return nothing
end

function rendering(xml_path::AbstractString, module_dir::AbstractString)::String
    io = IOBuffer()
    try
        loaded = load(xml_path, module_dir)
        render(io, loaded)
    catch e
        # Error behaviour is part of what a golden pins: a refactor must not turn a throw into a
        # silent wrong answer, nor the reverse. The type alone, since messages carry paths.
        println(io, "THREW ", typeof(e))
    end
    return String(take!(io))
end

@testset "Generic golden test" begin
    mkpath(GOLDEN_DIR)
    for (module_dir, xml_files) in generic_test_files, xml_path in xml_files
        name = get_base_name_without_extension(xml_path)
        @testset "Generic golden test - $name" begin
            actual = rendering(xml_path, module_dir)
            golden_path = joinpath(GOLDEN_DIR, name * ".txt")
            if get(ENV, "REGEN_GOLDENS", "0") == "1" || !isfile(golden_path)
                write(golden_path, actual)
                @info "wrote golden for $name ($(length(actual)) bytes)"
            end
            expected = read(golden_path, String)
            if actual != expected
                # Show the first difference rather than two walls of text.
                a = split(actual, '\n')
                b = split(expected, '\n')
                i = findfirst(j -> get(a, j, nothing) != get(b, j, nothing), 1:max(length(a), length(b)))
                @info "golden mismatch for $name at line $i" expected = get(b, i, "<missing>") actual = get(a, i, "<missing>")
            end
            @test actual == expected
        end
    end
end
