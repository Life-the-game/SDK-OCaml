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
val base_url : string

(* ************************************************************************** *)
(* Curl                                                                       *)
(* ************************************************************************** *)

(* Return a text from a url using Curl and HTTP Auth (if needed)              *)
val get_text_form_url :
  ?auth:((string * string) option) -> string -> string

(* Take a url, get the page and return a json tree                            *)
val curljson : string -> Yojson.Basic.json

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

type ('a, 'b) result = Success of 'a | Failure of 'b
type errors = ApiRsp.t list

(* Take a response tree, check error and return the result or the error(s)    *)
val get_content : Yojson.Basic.json -> (Yojson.Basic.json, errors) result

(* Generate a formatted URL with get parameters                               *)
(* Example: url ~parents:["a"; "b"] ~get:[("c", "d")] ~url:("http://g.com") ()*)
(*  Result: http://g.com/a/b?c=d                                              *)
val url :
  ?parents:(string list)
  -> ?get:((string * string) list)
  -> ?url:string  -> unit -> string
