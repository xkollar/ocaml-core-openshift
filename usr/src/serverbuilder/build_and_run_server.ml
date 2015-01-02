
let continue_with cmd args = Unix.execvp cmd (cmd::args |> Array.of_list)

let my_waitpid pid =
    ignore (Unix.waitpid [] pid)

let run cmd args =
    match Unix.fork () with
        | 0 -> continue_with cmd args
        | -1 -> Printf.printf "Error occurred on fork\n%!"
        | pid -> my_waitpid pid


let port = Unix.getenv "OPENSHIFT_OCAML_CORE_PORT"
let address = Unix.getenv "OPENSHIFT_OCAML_CORE_ADDRESS"
let cartridge_dir = Unix.getenv "OPENSHIFT_OCAML_CORE_DIR"

let () =
    Unix.environment ()
    |> Array.to_list
    |> String.concat "\n"
    |> Printf.printf "Building in environment:\n%s\n\n%!";
    run (cartridge_dir^"bin/build-server" ) ["5"];

    Printf.printf "Starting server\n%!";
    continue_with "server" ["-port"; port; "-address"; address]
