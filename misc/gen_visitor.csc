import visitorgen, ecs_parser
var ofs = iostream.ofstream("./ast_visitor.csp")
(new visitorgen.visitor_generator).run(ofs, ecs_parser.grammar.stx)