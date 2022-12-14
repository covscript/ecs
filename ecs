#!/usr/bin/env cs
@require: 210505
var bootstrap = context.import(runtime.get_import_path(), "ecs_bootstrap")
if bootstrap == null
    system.out.println("Error: ecs not installed yet.")
    system.out.println("Run \'cspkg install ecs_bootstrap\' to enjoy full feature.")
else
    bootstrap.main(context.cmd_args)
end