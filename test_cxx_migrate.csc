var _pg_impl = "parsergen"
try
    _pg_impl = system.getenv("PARSERGEN_IMPL")
catch e
end
var parsergen = context.import(runtime.get_import_path(), _pg_impl)
import ecs_parser, ecs_generator

var lex = ecs_parser.get_lexical_patterns(false)
var stx = ecs_parser.get_syntax(false)
var cxx_gram = parsergen.make_grammar_from(".*\\.(csp|csc|ecs|ecsx)", lex, stx)

var gen = new parsergen.generator
gen.set_show_prompt(false)
gen.add_language("ecs-lang", "ascii", cxx_gram)

var file = context.cmd_args.at(1)
if gen.from_file(file)
    system.out.println("PARSE OK")
    var codegen = new ecs_generator.generator
    codegen.code_buff = gen.get_code_buff()
    codegen.file_name = file
    codegen.minimal = true
    system.path.mkdir_p("./.ecs_output/")
    var result = codegen.run("./.ecs_output/test_migrated", gen.get_ast())
    if result != null
        system.out.println("CODEGEN OK: " + result)
    else
        system.out.println("CODEGEN FAIL")
    end
else
    system.out.println("PARSE FAIL")
    foreach it in gen.get_errors()
        system.out.println("  " + it.text())
    end
end
