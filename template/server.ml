(***************************
 * Can be build with
 * corebuild -package async server.native
 ***************************)

open Core.Std
open Async.Std

let run ~address ~port =
    let host_and_port =
        Tcp.Server.create
            ~on_handler_error:`Raise
            (Tcp.Where_to_listen.create
                ~socket_type:Socket.Type.tcp
                ~address:(`Inet (Unix.Inet_addr.of_string address, port))
                ~listening_on:(fun _ -> port))
            (fun _addr _r w ->
                printf "Accepted client\n";
                Writer.write w "HTTP/1.1 200 OK\r\n\r\nHello OCaml";
                Writer.flushed w)
    in
    ignore (host_and_port : (Socket.Address.Inet.t, int) Tcp.Server.t Deferred.t);
    Deferred.never ()

let () =
    Command.async_basic
        ~summary:"Start simple server"
        Command.Spec.(
            empty
            +> flag "-address" (optional_with_default "0.0.0.0" string)
               ~doc:"ADDRESS Address to bind to (default 0.0.0.0)"
            +> flag "-port" (optional_with_default 8080 int)
               ~doc:"PORT Port to listen on (default 8080)"
        )
        (fun address port () -> run ~address ~port)
    |> Command.run
