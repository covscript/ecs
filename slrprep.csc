# Parsing EBNF

import parsergen
import ebnf_syntax
import ebnf_parser

function parse_ebnf(file)
    # Generating AST of EBNF
    var generator = new parsergen.generator
    generator.add_grammar("ebnf-lang", ebnf_syntax.grammar)
    generator.enable_log = true
    generator.from_file(file)
    system.out.println("show ast");
    parsergen.print_ast(generator.ast);
    if generator.ast != null
        # Parsing EBNF AST
        var parser = new ebnf_parser.parser
        parser.parse(generator.ast)
        system.out.println("build successfully")
        return parser.res
    else
        system.out.println("build failed")
        return null
    end
end

system.out.println("start " + context.cmd_args.at(1))

var res = parse_ebnf(context.cmd_args.at(1))

system.out.println("parse ebnf end")

system.out.println("print ebnf: ")

function print_bnf(it, count)
    system.out.println(it.root)
    #system.out.println(it.seq)
    foreach subt in it.nodes
        foreach i in range(count) do system.out.print("\t")
        print_bnf(subt, count + 1)
    end
end

 foreach it in res do print_bnf(it, 1)

system.out.println("print ebnf end")

# Preparing for SLR Parsing

import slr_inspector

function slr_prep(bnf_tree, file)
    var LR_terms = new slr_inspector.LR_term
    var NFA = new slr_inspector.NFA_type
    var DFA = new slr_inspector.DFA_type
    LR_terms.run(bnf_tree, true)
    NFA.run(LR_terms.result, true)
    DFA.run(NFA.result_list, LR_terms.first_map, LR_terms.follow_map, true)
    DFA.create_predict_table()
    var ofs = iostream.ofstream(file)
    DFA.print_predict_table_as_json(ofs)
end

slr_prep(res, context.cmd_args.at(2))