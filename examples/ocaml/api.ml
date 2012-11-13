(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Get a page from a url using curl and return a json tree       *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

(* ?auth:((string * string) option) -> string -> string                       *)
(* Return a text from a url using Curl and HTTP Auth (if needed)              *)
let get_text_form_url ?(auth=None) url =
  let writer accum data =
    Buffer.add_string accum data;
    String.length data in
  let result = Buffer.create 4096
  and errorBuffer = ref "" in
  Curl.global_init Curl.CURLINIT_GLOBALALL;
  let text =
    try
      (let connection = Curl.init () in
       Curl.set_errorbuffer connection errorBuffer;
       Curl.set_writefunction connection (writer result);
       Curl.set_followlocation connection true;
       Curl.set_url connection url;
       
       (match auth with
	 | Some (username, password) ->
	   (Curl.set_httpauth connection [Curl.CURLAUTH_BASIC];
	    Curl.set_userpwd connection (username ^ ":" ^ password))
	 | _ -> ());

       Curl.perform connection;
       Curl.cleanup connection;
       Buffer.contents result)
    with
      | Curl.CurlException (_, _, _) ->
	raise (Failure ("Error: " ^ !errorBuffer))
      | Failure s -> raise (Failure s) in
  let _ = Curl.global_cleanup () in
  text

type 'a result = Success of 'a | Failure of string

(* string -> json                                                             *)
(* Take a url, get the page and return a json tree                            *)
let curljson url =
  let result = get_text_form_url url in
  Yojson.Basic.from_string result

let check_error tree =
  let open Yojson.Basic.Util in
  match tree with
    | `Assoc l ->
      (try (if (fst (List.hd l)) = "error"
	then Some ((snd (List.hd l)) |> to_string)
	else None)
       with _ -> None)
    | _ -> None
 
