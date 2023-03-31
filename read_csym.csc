function read_file(path)
    var ifs = iostream.ifstream(path)
    var data = new string
    loop
        var ch = ifs.get()
        if ifs.good() && !ifs.eof()
            data += ch
        else
            break
        end
    end
    return move(data)
end

var file = context.cmd_args[1]
var ecs_source = read_file("./tests/" + file + ".ecs").split({'\n'})
var csc_source = read_file(file + ".csc").split({'\n'})
var csym = read_file(file + ".csym").split({'\n'})
foreach i in range(csc_source.size)
    if csym[i][-1] == 'r'
        csym[i].pop_back()
    end
    if csym[i] == "INTERNAL"
        continue
    end
    system.out.println("CSC: " + csc_source[i])
    system.out.println("ECS: " + ecs_source[csym[i].to_number()])
    system.out.println("")
end
