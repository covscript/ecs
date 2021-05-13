#!/usr/bin/env cs
# Bootstrap of Extended Covariant Script Generator
import parsergen, ecs_parser, ecs_generator
import bitwise, regex

context.add_literal("hex", bitwise.hex_literal)

@begin
var crc32_tab = 
{
    "0x00000000"hex, "0x77073096"hex, "0xee0e612c"hex, "0x990951ba"hex, "0x076dc419"hex,
    "0x706af48f"hex, "0xe963a535"hex, "0x9e6495a3"hex, "0x0edb8832"hex, "0x79dcb8a4"hex,
    "0xe0d5e91e"hex, "0x97d2d988"hex, "0x09b64c2b"hex, "0x7eb17cbd"hex, "0xe7b82d07"hex,
    "0x90bf1d91"hex, "0x1db71064"hex, "0x6ab020f2"hex, "0xf3b97148"hex, "0x84be41de"hex,
    "0x1adad47d"hex, "0x6ddde4eb"hex, "0xf4d4b551"hex, "0x83d385c7"hex, "0x136c9856"hex,
    "0x646ba8c0"hex, "0xfd62f97a"hex, "0x8a65c9ec"hex, "0x14015c4f"hex, "0x63066cd9"hex,
    "0xfa0f3d63"hex, "0x8d080df5"hex, "0x3b6e20c8"hex, "0x4c69105e"hex, "0xd56041e4"hex,
    "0xa2677172"hex, "0x3c03e4d1"hex, "0x4b04d447"hex, "0xd20d85fd"hex, "0xa50ab56b"hex,
    "0x35b5a8fa"hex, "0x42b2986c"hex, "0xdbbbc9d6"hex, "0xacbcf940"hex, "0x32d86ce3"hex,
    "0x45df5c75"hex, "0xdcd60dcf"hex, "0xabd13d59"hex, "0x26d930ac"hex, "0x51de003a"hex,
    "0xc8d75180"hex, "0xbfd06116"hex, "0x21b4f4b5"hex, "0x56b3c423"hex, "0xcfba9599"hex,
    "0xb8bda50f"hex, "0x2802b89e"hex, "0x5f058808"hex, "0xc60cd9b2"hex, "0xb10be924"hex,
    "0x2f6f7c87"hex, "0x58684c11"hex, "0xc1611dab"hex, "0xb6662d3d"hex, "0x76dc4190"hex,
    "0x01db7106"hex, "0x98d220bc"hex, "0xefd5102a"hex, "0x71b18589"hex, "0x06b6b51f"hex,
    "0x9fbfe4a5"hex, "0xe8b8d433"hex, "0x7807c9a2"hex, "0x0f00f934"hex, "0x9609a88e"hex,
    "0xe10e9818"hex, "0x7f6a0dbb"hex, "0x086d3d2d"hex, "0x91646c97"hex, "0xe6635c01"hex,
    "0x6b6b51f4"hex, "0x1c6c6162"hex, "0x856530d8"hex, "0xf262004e"hex, "0x6c0695ed"hex,
    "0x1b01a57b"hex, "0x8208f4c1"hex, "0xf50fc457"hex, "0x65b0d9c6"hex, "0x12b7e950"hex,
    "0x8bbeb8ea"hex, "0xfcb9887c"hex, "0x62dd1ddf"hex, "0x15da2d49"hex, "0x8cd37cf3"hex,
    "0xfbd44c65"hex, "0x4db26158"hex, "0x3ab551ce"hex, "0xa3bc0074"hex, "0xd4bb30e2"hex,
    "0x4adfa541"hex, "0x3dd895d7"hex, "0xa4d1c46d"hex, "0xd3d6f4fb"hex, "0x4369e96a"hex,
    "0x346ed9fc"hex, "0xad678846"hex, "0xda60b8d0"hex, "0x44042d73"hex, "0x33031de5"hex,
    "0xaa0a4c5f"hex, "0xdd0d7cc9"hex, "0x5005713c"hex, "0x270241aa"hex, "0xbe0b1010"hex,
    "0xc90c2086"hex, "0x5768b525"hex, "0x206f85b3"hex, "0xb966d409"hex, "0xce61e49f"hex,
    "0x5edef90e"hex, "0x29d9c998"hex, "0xb0d09822"hex, "0xc7d7a8b4"hex, "0x59b33d17"hex,
    "0x2eb40d81"hex, "0xb7bd5c3b"hex, "0xc0ba6cad"hex, "0xedb88320"hex, "0x9abfb3b6"hex,
    "0x03b6e20c"hex, "0x74b1d29a"hex, "0xead54739"hex, "0x9dd277af"hex, "0x04db2615"hex,
    "0x73dc1683"hex, "0xe3630b12"hex, "0x94643b84"hex, "0x0d6d6a3e"hex, "0x7a6a5aa8"hex,
    "0xe40ecf0b"hex, "0x9309ff9d"hex, "0x0a00ae27"hex, "0x7d079eb1"hex, "0xf00f9344"hex,
    "0x8708a3d2"hex, "0x1e01f268"hex, "0x6906c2fe"hex, "0xf762575d"hex, "0x806567cb"hex,
    "0x196c3671"hex, "0x6e6b06e7"hex, "0xfed41b76"hex, "0x89d32be0"hex, "0x10da7a5a"hex,
    "0x67dd4acc"hex, "0xf9b9df6f"hex, "0x8ebeeff9"hex, "0x17b7be43"hex, "0x60b08ed5"hex,
    "0xd6d6a3e8"hex, "0xa1d1937e"hex, "0x38d8c2c4"hex, "0x4fdff252"hex, "0xd1bb67f1"hex,
    "0xa6bc5767"hex, "0x3fb506dd"hex, "0x48b2364b"hex, "0xd80d2bda"hex, "0xaf0a1b4c"hex,
    "0x36034af6"hex, "0x41047a60"hex, "0xdf60efc3"hex, "0xa867df55"hex, "0x316e8eef"hex,
    "0x4669be79"hex, "0xcb61b38c"hex, "0xbc66831a"hex, "0x256fd2a0"hex, "0x5268e236"hex,
    "0xcc0c7795"hex, "0xbb0b4703"hex, "0x220216b9"hex, "0x5505262f"hex, "0xc5ba3bbe"hex,
    "0xb2bd0b28"hex, "0x2bb45a92"hex, "0x5cb36a04"hex, "0xc2d7ffa7"hex, "0xb5d0cf31"hex,
    "0x2cd99e8b"hex, "0x5bdeae1d"hex, "0x9b64c2b0"hex, "0xec63f226"hex, "0x756aa39c"hex,
    "0x026d930a"hex, "0x9c0906a9"hex, "0xeb0e363f"hex, "0x72076785"hex, "0x05005713"hex,
    "0x95bf4a82"hex, "0xe2b87a14"hex, "0x7bb12bae"hex, "0x0cb61b38"hex, "0x92d28e9b"hex,
    "0xe5d5be0d"hex, "0x7cdcefb7"hex, "0x0bdbdf21"hex, "0x86d3d2d4"hex, "0xf1d4e242"hex,
    "0x68ddb3f8"hex, "0x1fda836e"hex, "0x81be16cd"hex, "0xf6b9265b"hex, "0x6fb077e1"hex,
    "0x18b74777"hex, "0x88085ae6"hex, "0xff0f6a70"hex, "0x66063bca"hex, "0x11010b5c"hex,
    "0x8f659eff"hex, "0xf862ae69"hex, "0x616bffd3"hex, "0x166ccf45"hex, "0xa00ae278"hex,
    "0xd70dd2ee"hex, "0x4e048354"hex, "0x3903b3c2"hex, "0xa7672661"hex, "0xd06016f7"hex,
    "0x4969474d"hex, "0x3e6e77db"hex, "0xaed16a4a"hex, "0xd9d65adc"hex, "0x40df0b66"hex,
    "0x37d83bf0"hex, "0xa9bcae53"hex, "0xdebb9ec5"hex, "0x47b2cf7f"hex, "0x30b5ffe9"hex,
    "0xbdbdf21c"hex, "0xcabac28a"hex, "0x53b39330"hex, "0x24b4a3a6"hex, "0xbad03605"hex,
    "0xcdd70693"hex, "0x54de5729"hex, "0x23d967bf"hex, "0xb3667a2e"hex, "0xc4614ab8"hex,
    "0x5d681b02"hex, "0x2a6f2b94"hex, "0xb40bbe37"hex, "0xc30c8ea1"hex, "0x5a05df1b"hex,
    "0x2d02ef8d"hex
}
@end

function crc32_file(path)
    var ifs = iostream.fstream(path, iostream.openmode.bin_in)
    if !ifs.good()
        return 0
    end
    var crc32val = "0xFFFFFFFF"hex
    loop
        var ch = ifs.get()
        if ifs.eof()
            break
        end
        crc32val = crc32_tab.at(crc32val.logic_xor(bitwise.bitset.from_number(to_integer(ch))).logic_and("0xFF"hex).to_number()).logic_xor(crc32val.shift_right(8).logic_and("0x00FFFFFF"hex))
    end
    return crc32val.logic_xor("0xFFFFFFFF"hex).to_hash()
end

function show_version()
@begin
    system.out.println(
        "Version: " + ecs_info.version + "\n" +
        "Copyright (C) 2017-2021 Michael Lee. All rights reserved.\n" +
        "Please visit http://covscript.org.cn/ for more information.\n\n" +
        "Metadata:\n" +
        "  STD Version: " + ecs_info.std_version + "\n"
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
    if output == null
        minmal = true
    end
    var crc32 = to_string(crc32_file(file_name)) + ".ecs_cache"
    if system.file.exist("./.ecs_output/" + crc32)
        var name = iostream.ifstream("./.ecs_output/" + crc32).getline()
        system.exit(no_run ? 0 : system.run("cs " + compiler_args + " " + name + arguments))
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
                iostream.ofstream("./.ecs_output/" + crc32).println(name)
                system.exit(no_run ? 0 : system.run("cs " + compiler_args + " " + name + arguments))
            end
        else
            system.path.mkdir_p("./.ecs_output/")
            var name = codegen.run("./.ecs_output/" + to_string(runtime.hash(file_name)), parser.ast)
            iostream.ofstream("./.ecs_output/" + crc32).println(name)
            system.exit(no_run ? 0 : system.run("cs " + compiler_args + " " + name + arguments))
        end
    end
end

main(context.cmd_args)