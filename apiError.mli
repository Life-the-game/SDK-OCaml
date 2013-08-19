(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/SDK-OCaml   *)
(* ************************************************************************** *)
(** Errors type, converter and client-side errors                             *)

(* ************************************************************************** *)
(** {3 Type}                                                                  *)
(* ************************************************************************** *)

type t =
    {
      message : string;
      stype   : string;
      code    : int;
    }

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val from_json : Yojson.Basic.json -> t

(* ************************************************************************** *)
(** {3 Client-side errors}                                                    *)
(* ************************************************************************** *)

val generic             : t
val network             : string -> t
val invalid_json        : string -> t
val requirement_missing : t
val invalid_format      : t
val invalid_argument    : string -> t
