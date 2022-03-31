| 文件 | 输入 | 输出 |
| --- | --- | --- |
| parsergen.csp(A) | 正则表达式 ebnf_syntax | ebnf_lexer(B) |
| parsergen.csp(A) | 文法规则 ebnf_syntax   | ebnf_parser(C) |
| ebnf_lexer(B) | ecs.ebnf文件 | ebnf_tokens(D) |
| ebnf_parser(C) | ebnf_token(D) | ebnf_ast(E) |
| visitor_generator.csp | 文法规则 | ebnf_parser[注:应叫visitor] (F) |
| ebnf_parser[应叫visitor] (F) | ebnf_ast | bnf |
| slr_ inspector.csp(G) | bnf | lr0_term |
| slr_parser(H) | lr0_term/ input_code | code_ast |
| slr_generator | code_ast | compressed_ast(cov ast) |  

