(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** Errors type, converter and client-side errors                             *)

(* ************************************************************************** *)
(** {3 Type}                                                                  *)
(* ************************************************************************** *)

type detail =
    {
      dcode : int;
      dtype : string;
      dmessage : string;
      key : string;
      value : string;
    }

type t =
    {
      message : string;
      stype   : string;
      code    : int;
      details : detail list;
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
val file_not_found      : t
val invalid_argument    : string -> t
val auth_required       : t
val notfound            : t
