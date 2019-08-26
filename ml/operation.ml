open Printf

type t =
  | Get of string
  | Put of string * string

let to_string = function
  | Get s      -> sprintf "get %s" s
  | Put (k, v) -> sprintf "put %s %s" k v
