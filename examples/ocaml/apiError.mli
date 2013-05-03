(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Responses Codes                                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Type                                                                       *)
(* ************************************************************************** *)

type t =
    {
      message : string;
      stype   : string;
      code    : int;
    }

(* ************************************************************************** *)
(* Success                                                                    *)
(* ************************************************************************** *)

val success : t

(* ************************************************************************** *)
(* Client-side errors                                                         *)
(* ************************************************************************** *)

val generic             : t
val network             : string -> t
val invalid_json        : string -> t
val requirement_missing : t
