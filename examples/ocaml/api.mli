(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Get a page from a url using curl and return a json tree       *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(** Configuration                                                             *)
(* ************************************************************************** *)

(** The URL of the API Web service                                            *)
val base_url : string

(* ************************************************************************** *)
(** Network                                                                   *)
(* ************************************************************************** *)

type request_type =
  | GET
  | POST
  | PUT
  | DELETE

(** Return a text from a url using Curl and HTTP Auth (if needed)             *)
val get_text_form_url :
  ?auth:((string * string) option)
  -> ?request_type:request_type
  -> string -> string

(** Generate a formatted URL with get parameters                              *)
(** Example: url ~parents:["a"; "b"] ~get:[("c", "d")] ~url:("http://g.com")  *)
(**  Result: http://g.com/a/b?c=d                                             *)
val url :
  ?parents:(string list)
  -> ?get:((string * string) list)
  -> ?url:string  -> unit -> string

(* ************************************************************************** *)
(** Transform content                                                         *)
(* ************************************************************************** *)

(** Take a response tree, check error and return the error and the result     *)
val get_content : Yojson.Basic.json -> (ApiError.t option * Yojson.Basic.json)

(* ************************************************************************** *)
(** Shortcuts                                                                 *)
(* ************************************************************************** *)

(** Take a url, get the page and return a json tree                           *)
val curljson : string -> Yojson.Basic.json

(** Take a url, get the pag into json, check and return error and result      *)
val curljsoncontent : string -> (ApiError.t option * Yojson.Basic.json)
