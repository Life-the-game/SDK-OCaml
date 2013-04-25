(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Get a page from a url using curl and return a json tree       *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Configuration                                                              *)
(* ************************************************************************** *)

(* The URL of the API Web service                                             *)
let base_url = "http://life.paysdu42.fr:2000"

(* ************************************************************************** *)
(** Network                                                                   *)
(* ************************************************************************** *)

type request_type =
  | GET
  | POST
  | PUT
  | DELETE

let request_type_to_string = function
  | GET    -> "GET"
  | POST   -> "POST"
  | PUT    -> "PUT"
  | DELETE -> "DELETE"

(* ?auth:((string * string) option) -> ?request_type:request)type             *)
(*  -> string -> string                                                       *)
(* Return a text from a url using Curl and HTTP Auth (if needed)              *)
let get_text_form_url ?(auth=None) ?(request_type=GET) url =
  let writer accum data =
    Buffer.add_string accum data;
    String.length data in
  let result = Buffer.create 4096
  and errorBuffer = ref "" in
  Curl.global_init Curl.CURLINIT_GLOBALALL;
  let text =
    try
      (let connection = Curl.init () in
       Curl.set_customrequest connection (request_type_to_string request_type);
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

(* ?parents:(string list) -> ?get:((string * string) list) -> ?url:string     *)
(*  -> unit -> string                                                         *)
(* Generate a formatted URL with get parameters                               *)
let url ?(parents = []) ?(get = []) ?(url = base_url) () =
  let parents = List.fold_left (fun f s -> f ^ "/" ^ s) "" parents
  and get =
    let url = (List.fold_left (fun f (s, v) -> f ^ "&" ^ s ^ "=" ^ v) "" get) in
    if (String.length url) = 0 then url else (String.set url 0 '?'; url) in
  url ^ parents ^ get

(* ************************************************************************** *)
(* Transform content                                                          *)
(* ************************************************************************** *)

(* Yojson.Basic.json -> (ApiError.t option * Yojson.Basic.json)               *)
(* Take a response tree, check error and return the error and the result      *)
let get_content tree =
  let open Yojson.Basic.Util in
      let error =
	let elt = tree |> member "error" in
	if (elt |> member "code" |> to_int) = 0
	then None
	else
	  (let open ApiError in
	       Some {
		 message = elt |> member "message" |> to_string;
		 stype   = elt |> member "stype"   |> to_string;
		 code    = elt |> member "code"    |> to_int;
	       })
      and element = tree |> member "element" in
      (error, element)

(* ************************************************************************** *)
(* Shortcuts                                                                  *)
(* ************************************************************************** *)

(* string -> Yojson.Basic.json                                                *)
(* Take a url, get the page and return a json tree                            *)
let curljson url =
  let result = get_text_form_url url in
  Yojson.Basic.from_string result

(* string -> (ApiError.t option * Yojson.Basic.json)                          *)
(* Take a url, get the pag into json, check and return error and result       *)
let curljsoncontent url = get_content (curljson url)

