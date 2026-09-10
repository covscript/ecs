import ecs_parser, parsergen_analysis
var report = parsergen_analysis.analyze(ecs_parser.grammar.stx)
var errors = 0
var warnings = 0
foreach it in report
    if it.find("[OVERLAP]", 0) == 0
        ++warnings
    else
        ++errors
    end
end
if report.empty()
    system.out.println("Grammar analysis: No issues found.")
else
    system.out.println("Grammar analysis: " + errors + " error(s), " + warnings + " warning(s):")
    foreach it in report
        system.out.println("  " + it)
    end
end
if errors > 0
    system.exit(1)
end
