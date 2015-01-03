open OASISTypes

let ctxt =
  {!OASISContext.default with
       OASISContext.ignore_plugins = true}

let pkg =
    OASISParse.from_file
      ~ctxt
      OASISParse.default_oasis_fn

let getdeps = function
    | Library (_, bs, _) -> bs.bs_build_depends
    | Object (_, bs, _) -> bs.bs_build_depends
    | Executable (_, bs, _) -> bs.bs_build_depends
    | _ -> []

let getpackagenames = function
    | FindlibPackage (n, _) -> [n]
    | _ -> []

let dependencies : string list = pkg.sections
    |> List.map getdeps
    |> List.concat
    |> List.map getpackagenames
    |> List.concat


let arguments = List.append ["install"; "-y"] dependencies

let run cmd args = Unix.execvp cmd (cmd::args |> Array.of_list)

let () =
    run "opam" arguments
