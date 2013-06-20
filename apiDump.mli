(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Module to pretty print the values returned by the API library *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(** Tools                                                                     *)
(* ************************************************************************** *)

val lprint_string : string -> unit
val lprint_endline : string -> unit
val verbose : string -> unit

(* ************************************************************************** *)
(** Dump results in a human readable format                                   *)
(* ************************************************************************** *)

val available_languages : unit -> unit
val error : ApiError.t -> unit
val list : 'a ApiTypes.List.t -> ('a -> unit) -> unit
val print : 'a -> unit
