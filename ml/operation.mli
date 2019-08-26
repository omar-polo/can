type t = Get of string | Put of string * string
val to_string : t -> string
