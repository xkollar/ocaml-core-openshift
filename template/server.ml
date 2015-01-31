module Fact = struct
  let rec fact n = if n == 0 then 1 else n * fact (n-1)

  let int_option_of_string s =
    try
      Some (int_of_string s)
    with error -> None

  let generate_info_page (cgi : Netcgi.cgi_activation) =
    let out = cgi # output # output_string in
    out "?n=<int>"

  let generate_result_page (cgi : Netcgi.cgi_activation) n =
    let out = cgi # output # output_string in
    out (fact n |> string_of_int)

  let generate_page (cgi : Netcgi.cgi_activation) =
    match cgi # argument_value "n" |> int_option_of_string with
    | None -> generate_info_page cgi
    | Some n -> generate_result_page cgi n

  let process (cgi : Netcgi.cgi_activation) =
    cgi # set_header
      ~cache:`No_cache
      ~content_type:"text/plain; charset=\"iso-8859-1\""
      ();
    generate_page cgi;
    cgi # output # commit_work()

  let handler =
    { Nethttpd_services.dyn_handler = (fun _ -> process);
      dyn_activation = Nethttpd_services.std_activation `Std_activation_buffered;
      dyn_uri = None; (* not needed *)
      dyn_translator = (fun _ -> ""); (* not needed *)
      dyn_accept_all_conditionals = false;
    }
end

module Webhook = struct
  let get_json_request (cgi : Netcgi.cgi_activation) =
    cgi # argument_value "BODY"
    |> Yojson.Basic.from_string

  let process_json_request jreq =
    let dir =  Unix.getenv "OPENSHIFT_DATA_DIR" in

    let oc = open_out_gen [Open_append; Open_creat] 0o600 (dir ^ "hooklog") in

    let open Yojson.Basic.Util in

    jreq |> member "action" |> to_string
    |> Printf.fprintf oc "%s\n";
    jreq |> Yojson.Basic.to_string
    |> Printf.fprintf oc "%s\n";
    close_out oc

  let generate_page (cgi : Netcgi.cgi_activation) =
    get_json_request cgi |> process_json_request;
    `Assoc ["response", `String "noted"]
    |> Yojson.Basic.to_output cgi # out_channel

  let process (cgi : Netcgi.cgi_activation) =
    cgi # set_header
      ~cache:`No_cache
      ~content_type:"application/json; charset=UTF-8"
      ();
    generate_page cgi;
    cgi # out_channel # commit_work ()

  let handler =
    { Nethttpd_services.dyn_handler = (fun _ -> process);
      dyn_activation = Nethttpd_services.std_activation `Std_activation_buffered;
      dyn_uri = None; (* not needed *)
      dyn_translator = (fun _ -> ""); (* not needed *)
      dyn_accept_all_conditionals = false;
    }
end

let service_factory = Nethttpd_plex.nethttpd_factory
  ~config_cgi:Netcgi.({
    default_config with
    default_exn_handler = false;
    permitted_input_content_types = [
      "application/json";
    ] @ default_config.permitted_input_content_types})
  ~handlers:[
    "fact_service", Fact.handler;
    "hook_service", Webhook.handler
  ]

let main () =
  (* Decault config, to be overwritten by command-line arguments *)
  let defaults = let dir = Unix.getenv "OPENSHIFT_DATA_DIR" in
    Netplex_main.create
      ~config_filename:(dir ^ "server.conf")
      ~pidfile:(Some (dir ^ "server.pid"))
      ()
  in

  (* Create a parser for the standard Netplex command-line arguments: *)
  let (opt_list, cmdline_cfg) = Netplex_main.args ~defaults () in

  let cfg = cmdline_cfg in

  (* Parse the command-line arguments: *)
  Arg.parse
    opt_list
    (fun s -> raise (Arg.Bad ("Don't know what to do with: " ^ s)))
    "usage: netplex [options]";

  (* Select multi-processing: *)
  let parallelizer = Netplex_mt.mt () in

  (* Start the Netplex system: *)
  Netplex_main.startup
    parallelizer
    Netplex_log.logger_factories
    Netplex_workload.workload_manager_factories
    [ service_factory () ]
    cfg

let () =
  (*
  Sys.getcwd ()
  |> Printf.printf "CWD: %s\n%!";

  Unix.environment ()
  |> Array.to_list
  |> String.concat "\n"
  |> Printf.printf "Running in environment:\n%s\n\n%!";
  *)

  Sys.set_signal Sys.sigpipe Sys.Signal_ignore;
  if not !Sys.interactive
  then main ()
  else ()
