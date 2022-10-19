#!/usr/bin/env cs
# Bootstrap of Extended Covariant Script Generator
import parsergen, ecs_parser, ecs_generator
import codec, regex

var wrapper_ver = "1.3.1"

function show_version()
@begin
    system.out.println(
        "Version: " + ecs_generator.ecs_info.version + ", Wrapper " + wrapper_ver + "\n" +
        "Copyright (C) 2017-2022 Michael Lee. All rights reserved.\n" +
        "Please visit http://covscript.org.cn/ for more information.\n\n" +
        "Metadata:\n" +
        "  STD Version: " + ecs_generator.ecs_info.std_version + "\n"
    )
@end
    system.exit(0)
end

function show_help()
@begin
    system.out.println(
        "Usage: ecs [options...] <FILE> [arguments...]\n\n" +
        "Options:\n" +
        "    Option    Function\n" +
        "   -h         Show help information\n" +
        "   -v         Show version infomation\n" +
        "   -f         Disable compile cache\n" +
        "   -m         Disable beautify\n" +
        "   -c         Check grammar only\n" +
        "   -o <PATH>  Set output path\n" +
        "   -- <ARGS>  Pass parameters to CovScript\n"
    )
@end
    system.exit(0)
end

var compiler_args = new string
var file_name = new string
var arguments = new string
var no_hash = false
var minmal = false
var no_run = false
var output = null

function process_args(cmd_args)
    var index = 1
    while index < cmd_args.size && cmd_args[index][0] == '-'
        switch cmd_args[index]
            default
                system.out.println("Error: Unknown option \"" + cmd_args[index] + "\"")
                system.exit(0)
            end
            case "-v"
                show_version()
            end
            case "-h"
                show_help()
            end
            case "-f"
                no_hash = true
            end
            case "-m"
                minmal = true
            end
            case "-c"
                no_run = true
            end
            case "-o"
                if index == cmd_args.size - 1
                    system.out.println("Error: Option \"-o\" not completed. Usage: \"ecs -o <PATH>\"")
                    system.exit(0)
                end
                output = cmd_args[++index]
            end
            case "--"
                if index == cmd_args.size - 1
                    system.out.println("Error: Option \"--\" not completed. Usage: \"ecs -- <ARGS>\"")
                    system.exit(0)
                end
                compiler_args = cmd_args[++index]
            end
        end
        ++index
    end
    if index == cmd_args.size
        system.out.println("Error: no input file.")
        system.exit(0)
    end
    file_name = cmd_args[index++]
    while index < cmd_args.size
        arguments += " " + cmd_args[index++] 
    end
end

var ecs_reg = regex.build("^(.*)\\.ecs$")
var lcs_reg = regex.build("^(.*)\\.(csc|csp)$")

function match(reg, str)
    return !reg.match(str).empty()
end

function main(cmd_args)
    process_args(cmd_args)
    if !system.file.exist(file_name) || !match(regex.build(ecs_parser.grammar.ext), file_name)
        system.out.println("Error: invalid input file.")
        system.exit(0)
    end
    var file_hash = null
    if !no_hash
        file_hash = codec.sha256.hash_file(file_name) + ".ecs_cache"
        if output == null
            minmal = true
            if system.file.exist("./.ecs_output/" + file_hash)
                var name = iostream.ifstream("./.ecs_output/" + file_hash).getline()
                system.exit(no_run ? 0 : system.run("cs " + compiler_args + " " + name + arguments))
            end
        end
    end
    var parser = new parsergen.generator
    parser.add_grammar("ecs-lang", ecs_parser.grammar)
    parser.from_file(file_name)
    if parser.ast != null
        if match(lcs_reg, file_name)
            system.exit(no_run ? 0 : system.run("cs " + compiler_args + " " + file_name + arguments))
        end
        var codegen = new ecs_generator.generator
        codegen.code_buff = parser.code_buff
        codegen.file_name = file_name
        codegen.minmal = minmal
        if output != null
            var result = ecs_reg.match(file_name)
            if !result.empty()
                var name = codegen.run(output + system.path.separator + result.str(1).split({'\\', '/'})[-1], parser.ast)
                if !no_hash
                    iostream.ofstream("./.ecs_output/" + file_hash).println(name)
                end
                system.exit(no_run ? 0 : system.run("cs " + compiler_args + " " + name + arguments))
            end
        else
            system.path.mkdir_p("./.ecs_output/")
            var name = codegen.run("./.ecs_output/" + codec.sha256.hash_str(file_name), parser.ast)
            if !no_hash
                iostream.ofstream("./.ecs_output/" + file_hash).println(name)
            end
            system.exit(no_run ? 0 : system.run("cs " + compiler_args + " " + name + arguments))
        end
    end
end

main(context.cmd_args)