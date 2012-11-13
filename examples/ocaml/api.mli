(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Get a page from a url using curl and return a json tree       *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

type 'a result = Success of 'a | Failure of string

(* Return a text from a url using Curl and HTTP Auth (if needed)              *)
val get_text_form_url :
  ?auth:((string * string) option) -> string -> string

(* Take a url, get the page and return a json tree                            *)
val curljson : string -> Yojson.Basic.json

val check_error : Yojson.Basic.json -> string option
