(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Get a page from a url using curl and return a json tree       *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Configuration                                                              *)
(* ************************************************************************** *)

(* The URL of the API                                                         *)
let base_url = "http://life.paysdu42.fr:2000"

(* ************************************************************************** *)
(* Curl                                                                       *)
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

(* string -> Yojson.Basic.json                                                *)
(* Take a url, get the page and return a json tree                            *)
let curljson url =
  let result = get_text_form_url url in
  Yojson.Basic.from_string result

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

type ('a, 'b) result = Success of 'a | Failure of 'b
type errors = ApiRsp.t list

(* Yojson.Basic.json -> (Yojson.Basic.json, errors) result                    *)
(* Take a response tree, check error and return the result or the error(s)    *)
let get_content tree =
  let open Yojson.Basic.Util in
      let rspcode = tree |> member "rspcode" |> to_int
      and rspmsg  = tree |> member "rspmsg"  |> to_string
      and content = tree |> member "content" in
      if rspcode = 0
      then Success content
      else Failure [(rspcode, rspmsg)] (* todo: multiple errors *)

(* ?parents:(string list) -> ?get:((string * string) list) -> ?url:string     *)
(*  -> unit -> string                                                         *)
(* Generate a formatted URL with get parameters                               *)
let url ?(parents = []) ?(get = []) ?(url = base_url) () =
  let parents = List.fold_left (fun f s -> f ^ "/" ^ s) "" parents
  and get =
    let url = (List.fold_left (fun f (s, v) -> f ^ "&" ^ s ^ "=" ^ v) "" get) in
    if (String.length url) = 0 then url else (String.set url 0 '?'; url) in
  url ^ parents ^ get
