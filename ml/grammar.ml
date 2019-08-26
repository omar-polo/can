module Token = struct
  type t =
    | Get
    | Put
    | Symbol of string

  let to_symbol x = match x with
    | Get -> Symbol "get"
    | Put -> Symbol "put"
    | Symbol x -> Symbol x

  let to_string x = match x with
    | Get -> "get"
    | Put -> "put"
    | Symbol x -> x

  let parse w = match w with
    | "get" -> Get
    | "put" -> Put
    | _     -> Symbol w
end

let normalize cmd = match cmd with
  | Token.Get::ts -> Token.Get::(List.map Token.to_symbol ts)
  | Token.Put::ts -> Token.Put::(List.map Token.to_symbol ts)
  | _             -> cmd

let lexer line =
  Str.split (Str.regexp " ") line
  |> List.map Token.parse
  |> normalize

let parser ts =
  match ts with
  | Token.Get::(Symbol x)::[] -> Some (Operation.Get x)
  | Token.Put::(Symbol k)::(Symbol v)::[] -> Some (Operation.Put (k, v))
  | _ -> None
       
let valid cmd = match parser cmd with
  | Some _ -> true
  | None   -> false

let parse s = s |> lexer |> parser
