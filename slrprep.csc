# Parsing EBNF

import parsergen
import ebnf_syntax
import ebnf_parser

function parse_ebnf(file)
    # Generating AST of EBNF
    var generator = new parsergen.generator
    generator.add_grammar("ebnf-lang", ebnf_syntax.grammar)
    generator.enable_log = false
    generator.from_file(file)
    if generator.ast != null
        # Parsing EBNF AST
        var parser = new ebnf_parser.parser
        parser.parse(generator.ast)
        return parser.res
    else
        return null
    end
end

var res = parse_ebnf(context.cmd_args.at(1))

function print_bnf(it, count)
    system.out.println(it.root)
    #system.out.println(it.seq)
    foreach subt in it.nodes
        foreach i in range(count) do system.out.print("\t")
        print_bnf(subt, count + 1)
    end
end

# foreach it in res do print_bnf(it, 1)

# Preparing for SLR Parsing

import slr_inspector

function slr_prep(bnf_tree, file)
    var LR_terms = new slr_inspector.LR_term
    var NFA = new slr_inspector.NFA_type
    var DFA = new slr_inspector.DFA_type
    LR_terms.run(bnf_tree, false)
    NFA.run(LR_terms.result, false)
    DFA.run(NFA.result_list, LR_terms.first_map, LR_terms.follow_map, false)
    DFA.create_predict_table()
    var ofs = iostream.ofstream(file)
    DFA.print_predict_table_as_json(ofs)
end

slr_prep(res, context.cmd_args.at(2))