open Printf
open Unix
open Thread

let readline () =
  try
    Some (read_line ())
  with
    End_of_file -> None

(* let rec main line =
 *   match line with
 *   | Some line -> (match Grammar.parse line with
 *                   | Some cmd -> printf "%s\n" (Operation.to_string cmd)
 *                   | None     -> printf "Error: malformed cmd \"%s\"\n" line);
 *                  main (readline ())
 *   | None      -> () *)

let handle cin cout =
  while true do
    let line = input_line cin in
    match Grammar.parse line with
    | Some cmd -> fprintf cout "TODO: exec %s\n" (Operation.to_string cmd)
    | None     -> fprintf cout "Error: malformed cmd: \"%s\"\n" line
  done;
  ()

let conn_main sock =
  let cout = out_channel_of_descr sock
  and cin  = in_channel_of_descr sock in
  try
    handle cin cout
  with
    End_of_file -> ()

let rec accept_loop sock =
  let (s, addr) = accept sock in
  (match addr with
   | ADDR_INET (addr, port) -> printf "new connection from %s:%d" (string_of_inet_addr addr) port
   | _ -> printf "impossible\n");
  let _ = Thread.create conn_main s in
  accept_loop sock

let () =
  printf "in main\n";
  Sys.set_signal Sys.sigpipe Sys.Signal_ignore;
  let port = 4040 in
  let sock = socket PF_INET SOCK_STREAM 0 in
  setsockopt sock SO_REUSEADDR true;
  (* bind sock (ADDR_INET (inet_addr_of_string "0.0.0.0", port)); *)
  bind sock (ADDR_INET (inet_addr_of_string "127.0.0.1", port));
  listen sock 5;
  printf "listening on %d\n" port;
  accept_loop sock
