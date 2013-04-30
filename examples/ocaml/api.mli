(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Get a page from a url using curl and return a json tree       *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(** Types                                                                     *)
(* ************************************************************************** *)

(** Api Response                                                              *)
type 'a t =
  | Result of 'a
  | Error of ApiError.t

type login    = string
type password = string
type url      = string
type curlauth = (login * password)

(* ************************************************************************** *)
(** Configuration                                                             *)
(* ************************************************************************** *)

(** The URL of the API Web service                                            *)
val base_url : url

(* ************************************************************************** *)
(** Network                                                                   *)
(* ************************************************************************** *)

module type REQUESTTYPE =
sig
  type t =
    | GET
    | POST
    | PUT
    | DELETE
  val default   : t
  val to_string : t -> string
  val of_string : string -> t
end
module RequestType : REQUESTTYPE

(** Return a text from a url using Curl and HTTP Auth (if needed)             *)
val get_text_form_url :
  ?auth:(curlauth option)
  -> ?rtype:RequestType.t
  -> url
  -> string

(** Generate a formatted URL with get parameters                              *)
(** Example: url ~parents:["a"; "b"] ~get:[("c", "d")] ~url:("http://g.com")  *)
(**  Result: http://g.com/a/b?c=d                                             *)
val url :
  ?parents:(string list)
  -> ?get:((string * string) list)
  -> ?url:url
  -> unit
  -> url

(* ************************************************************************** *)
(** Transform content                                                         *)
(* ************************************************************************** *)

(** Take a response tree, check error and return the error and the result     *)
val get_content : Yojson.Basic.json -> (ApiError.t option * Yojson.Basic.json)

(* ************************************************************************** *)
(** Shortcuts                                                                 *)
(* ************************************************************************** *)

(** Take a url, get the page and return a json tree                           *)
val curljson :
  ?auth:(curlauth option)
  -> ?rtype:RequestType.t
  -> url
  -> Yojson.Basic.json

(** Take a url, get the pag into json, check and return error and result      *)
val curljsoncontent :
  ?auth:((login * password) option)
  -> ?rtype:RequestType.t
  -> url
  -> (ApiError.t option * Yojson.Basic.json)

(* ************************************************************************** *)
(** Ultimate shortcuts                                                        *)
(* ************************************************************************** *)

(** Handle an API method completely. Take a function to transform the json.   *)
val go :
  ?auth:(curlauth option)
  -> ?rtype:RequestType.t
  -> url
  -> (Yojson.Basic.json -> 'a)
  -> 'a t

(** In case the method does not return anything on success, use this to handl *)
(** the whole request (curljsoncontent + return unit result)                  *)
val noop :
  ?auth:(curlauth option)
  -> ?rtype:RequestType.t
  -> url
  -> unit t
