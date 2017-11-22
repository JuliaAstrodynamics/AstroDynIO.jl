using AstroDynIO
using AstroDynBase
using Base.Test

@testset "CCSDS Orbit Data Messages" begin
    lines = open(readlines, @__FILE__, "r")
    @test_throws AstroDynError readheader(lines)

    lines = open(readlines, "goes.omm", "r")
    @test_throws AstroDynError readoem(lines)

    lines = open(readlines, "gmat.oem", "r")

    typ, version, date, originator = readheader(lines)
    @test AstroDynIO.parse_dayofyear("2007-065T16:00:00") == DateTime("2007-03-06T16:00:00")
    @test typ == :OEM
    @test version == v"1.0"
    @test date == DateTime("2017-10-26T16:38:14")
    @test originator == "GMAT USER"

    @test AstroDynIO.meta_indices(lines) == [(6,16), (144, 154)]
    
    ephemeris_line = lines[141]

    @test AstroDynIO.parse_ephemeris(ephemeris_line, UTC) == (UTCEpoch("2000-01-01T15:19:28.000"),
        [7.047357321847970e+003, -8.210037612352152e+002, 1.196005986196907e+003, 8.470864256867849e-001, 7.306239087955987e+000, 1.130362550626059e+000])

    trajs = readoem(lines)
end