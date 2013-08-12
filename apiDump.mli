(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/SDK-OCaml   *)
(* ************************************************************************** *)
(** Pretty print the values returned by the API library                       *)

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val lprint_string : string -> unit
val lprint_endline : string -> unit
val verbose : string -> unit

(* ************************************************************************** *)
(** {3 Dump results in a human readable format}                               *)
(* ************************************************************************** *)

val available_languages : unit -> unit
val error : ApiError.t -> unit
val page  : 'a ApiTypes.Page.t -> ('a -> unit) -> unit
val print : 'a -> unit
