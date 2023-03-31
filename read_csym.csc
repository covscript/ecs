import regex

var csym_regex = regex.build("^#\\$cSYM/1\\.0\\(([^\\)]*)\\):(.*)$")

function read_ifs_impl(ifs, data)
    var line = new string
    var expect_n = false
    loop
        var ch = ifs.get()
        if ifs.good() && !ifs.eof()
            if expect_n
                expect_n = false
                if ch != '\n'
                    line += '\r'
                end
            end
            if ch == '\n'
                data.push_back(line)
                line = new string
                continue
            end
            if ch == '\r'
                expect_n = true
                continue
            end
            line += ch
        else
            break
        end
    end
    if !line.empty()
        data.push_back(line)
    end
end

function read_file(path)
    var ifs = iostream.ifstream(path)
    var data = new array
    read_ifs_impl(ifs, data)
    return move(data)
end

struct csym_type
    var file = null
    var map = null
end

function read_csym(path)
    var ifs = iostream.ifstream(path)
    var data = new array
    var csym = ifs.getline()
    var csym_match = csym_regex.match(csym)
    if !csym_match.empty()
        var csym_obj = new csym_type
        csym_obj.file = csym_match.str(1)
        csym_obj.map = csym_match.str(2).split({','})
        read_ifs_impl(ifs, data)
        return {move(csym_obj), move(data)}
    else
        return null
    end
end

function alignment(str)
    var ss = str
    foreach i in range(str.size)
        if str[i] == '\t'
            ss.assign(i, ' ')
        end
    end
    return move(ss)
end

var file = context.cmd_args[1]
var csc_source = null
if system.file.exist(file + ".csc")
    csc_source = read_file(file + ".csc")
else
    csc_source = read_file(file + ".csp")
end
var (csym, ecs_source) = read_csym(file + ".csym")
system.out.println("In file " + csym.file + ":")
foreach i in range(csc_source.size)
    if csym.map[i] == "-"
        continue
    end
    system.out.println("CSC: " + alignment(csc_source[i]))
    system.out.println("ECS: " + ecs_source[csym.map[i].to_number()])
    system.out.println("")
end
