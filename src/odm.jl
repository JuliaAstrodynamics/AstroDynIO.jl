import AstroDynBase: AstroDynError, Epoch

export readoem, readheader

function readoem(lines)
    typ, version, date, originator = readheader(lines)
    if typ != :OEM
        throw(AstroDynError("Not an OEM file"))
    end
    [nothing]
end

function readheader(lines)
    if !startswith(lines[1], "CCSDS")
        throw(AstroDynError("Not a valid CCSDS file."))
    end
    typ = Symbol(split(lines[1], "_")[2])
    version = VersionNumber(split(lines[1])[end])

    dateidx = findfirst(startswith.(lines, "CREATION_DATE"))
    origidx = findfirst(startswith.(lines, "ORIGINATOR"))

    datestr = split(lines[dateidx])[end]
    if ismatch(r"[0-9]{4}-[0-9]{3}", datestr)
        date = parse_dayofyear(datestr)
    else
        date = DateTime(datestr)
    end
    originator = strip(split(lines[origidx], "=")[end])

    typ, version, date, originator
end

function parse_dayofyear(str)
    year = parse(Int, str[1:4])
    day = parse(Int, str[6:8])
    date = string(Dates.Date(year) + Dates.Day(day - 1))
    DateTime(date * str[9:end])
end

function parse_ephemeris(line, scale)
    parts = split(line)
    ep = Epoch{scale}(parts[1])
    rv = parse.(Float64, parts[2:end])
    ep, rv
end

function meta_indices(lines)
    start_indices = find(startswith.(lines, "META_START")) + 1
    stop_indices = find(startswith.(lines, "META_STOP")) - 1
    collect(zip(start_indices, stop_indices))
end