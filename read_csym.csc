function read_file(path)
    var ifs = iostream.ifstream(path)
    var line = new string
    var data = new array
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
    return move(data)
end

var file = context.cmd_args[1]
var ecs_source = read_file("./tests/" + file + ".ecs")
var csc_source = read_file(file + ".csc")
var csym = read_file(file + ".csym")
foreach i in range(csc_source.size)
    if csym[i] == "INTERNAL"
        continue
    end
    system.out.println("CSC: " + csc_source[i])
    system.out.println("ECS: " + ecs_source[csym[i].to_number()])
    system.out.println("")
end
