import codec.json as json
import slr_inspector
import slr_parser
import slr_generator
import regex
import parsergen

@begin
var covscript_lexical = {
    "ENDL" : regex.build("^\\n+$"),
    "ID" : regex.build("^[A-Za-z_]\\w*$"),
    "NUM" : regex.build("^[0-9]+\\.?([0-9]+)?$"),
    "STR" : regex.build("^(\"|\"([^\"]|\\\\\")*\"?)$"),
    "CHAR" : regex.build("^(\'|\'([^\']|\\\\(0|\\\\|\'|\"|\\w))\'?)$"),
    "BSIG" : regex.build("^(;|:=?|\\?|\\.\\.?|\\.\\.\\.)$"),
    "MSIG" : regex.build("^(\\+(\\+|=)?|-(-|=|>)?|\\*=?|/=?|%=?|\\^=?)$"),
    "LSIG" : regex.build("^(>|<|&|(\\|)|&&|(\\|\\|)|!|==?|!=?|>=?|<=?)$"),
    "BRAC" : regex.build("^(\\(|\\)|\\[|\\]|\\{|\\}|,)$"),
    "PREP" : regex.build("^@.*$"),
    "ign" : regex.build("^([ \\f\\r\\t\\v]+|#.*)$"),
    "err" : regex.build("^(\"|\'|(\\|)|\\.\\.)$")
}.to_hash_map()
@end

function read_cache(file)
    var ifs = iostream.ifstream(file)
    var json_obj = json.to_var(json.from_stream(ifs))
    var predict_table = new array
    foreach it in json_obj
        var rules = new hash_map
        foreach rule in it.second
            if rule.second.TYP == "R"
                var term = new slr_inspector.LR_type
                term.root = rule.second.TGT
                term.origin_nodes = rule.second.NODE
                rules.insert(rule.first, move(term))
            else
                rules.insert(rule.first, rule.second.TGT)
            end
        end
        predict_table.push_back(it.first.to_number() : move(rules))
    end
    predict_table.sort([](lhs, rhs)->lhs.first < rhs.first)
    var result = new array
    foreach it in predict_table do result.push_back(move(it.second))
    return move(result)
end

function from_file(path)
    var ifs = iostream.ifstream(path)
    if !ifs.good()
        return
    end
    var input = new string
    while ifs.good()
        var line = ifs.getline()
        input += line + "\n"
        for i = 0, i < line.size, ++i
            if line[i] == '\t'
                line.assign(i, ' ')
            end
        end
    end
    return input
end


var predict_table = read_cache(context.cmd_args.at(1))
var parser = new slr_parser.slr_parser_type
var code = from_file(context.cmd_args.at(2))
var tree_compress = new slr_generator.compress_tree
parser.run(code, predict_table, covscript_lexical, true)
parser.slr_lex()

# Problem here
parser.slr_parse()

system.out.println("\n\n")
parsergen.print_header("SHOW TREE")
parser.show_trees(parser.tree_stack.back, 0)

system.out.println("\n\n")
parsergen.print_header("SHOW ERROR")
parser.show_error()

# system.out.println("\n\n")
# parsergen.print_header("COMPRESS TREE")
# tree_compress.test1()
# tree_compress.run(parser.tree_stack.back)
# slr_generator.test()