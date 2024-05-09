app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.10.0/vNe6s9hWzoTZtFmNkvEICPErI9ptji_ySjicO6CkucY.tar.br",
    weaver: "https://github.com/smores56/weaver/releases/download/0.2.0/BBDPvzgGrYp-AhIDw0qmwxT0pWZIQP_7KOrUrZfp_xw.tar.br",
}

import pf.Stdout
import pf.Arg
import pf.Task exposing [Task]
import weaver.Opt
import weaver.Cli
import weaver.Param

Person : { name : Str, age : U8 }

evan : Person
evan = { name: "Evan", age: 128 }

greet : { name : Str }* -> Task {} _
greet = \{ name } -> Stdout.line! "Hello, $(name)!"

addHttps : { url : Str }a -> { url : Str }a
addHttps = \record ->
    { record & url: "https://$(record.url)" }

main : Task {} _
main =
    when Cli.parseOrDisplayMessage cliParser Arg.list! is
        Ok data ->
            Stdout.line! "Successfully parsed! Here's what I got:"
            Stdout.line! ""
            Stdout.line! (Inspect.toStr data)

            if data.alpha == 42 && data.force then
                greet evan
            else
                Task.ok {}

        Err message ->
            Stdout.line! message
            Task.err (Exit 1 "")

cliParser =
    Cli.weave {
        alpha: <- Opt.u64 { short: "a", help: "Set the alpha level." },
        force: <- Opt.flag { short: "f", help: "Force the task to complete." },
        file: <- Param.maybeStr { name: "file", help: "The file to process." },
        files: <- Param.strList { name: "files", help: "The rest of the files." },
    }
    |> Cli.finish {
        name: "basic",
        version: "v0.1.0",
        authors: ["Some One <some.one@mail.com>"],
        description: [
            "This is a basic example of what you can build with Weaver. You",
            "get safe parsing, useful error messages, and help pages all for",
            "free!",
        ]
        |> Str.joinWith " ",
    }
    |> Cli.assertValid
