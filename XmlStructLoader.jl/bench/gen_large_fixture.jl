# Generates a large XML instance document for bench/fixtures/large_synthetic.xsd - N repeated
# <Entry> records, matching the shape of a repeated-record financial message. Regenerate with:
#
#   julia --project=bench bench/gen_large_fixture.jl [N]
#
# Default N=20_000. The .xsd is small and hand-written (fixtures/large_synthetic.xsd); only the
# .xml instance needs to scale, so it's what this script (re)builds.

using Dates, Random

const HERE = @__DIR__
const N = isempty(ARGS) ? 20_000 : parse(Int, ARGS[1])

Random.seed!(0)
currencies = ("EUR", "USD", "GBP", "JPY", "CHF")

open(joinpath(HERE, "fixtures", "large_synthetic.xml"), "w") do io
    println(io, """<?xml version="1.0"?>""")
    println(
        io,
        """<LargeSynthetic:document xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="LargeSynthetic large_synthetic.xsd" xmlns:LargeSynthetic="LargeSynthetic">""",
    )
    for i in 1:N
        amount = round(rand() * 100_000, digits = 2)
        currency = currencies[(i % length(currencies)) + 1]
        date = DateTime(2024, 1, 1) + Dates.Second(i * 37)
        credit = isodd(i)
        println(io, "  <Entry>")
        println(io, "    <EntryId>ENTRY-$(lpad(i, 8, '0'))</EntryId>")
        println(io, "    <Amount>$amount</Amount>")
        println(io, "    <Currency>$currency</Currency>")
        println(io, "    <BookingDate>$(Dates.format(date, dateformat"yyyy-mm-ddTHH:MM:SS"))</BookingDate>")
        println(io, "    <CreditDebitIndicator>$credit</CreditDebitIndicator>")
        println(io, "    <Reference>REF-$(i)-$(hash(i) % 1_000_000)</Reference>")
        println(io, "  </Entry>")
    end
    println(io, "</LargeSynthetic:document>")
end

println("wrote ", N, " entries -> ", joinpath(HERE, "fixtures", "large_synthetic.xml"))
