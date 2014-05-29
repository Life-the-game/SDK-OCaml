(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: nox                                                                *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** {e For developers only. Use comments methods in corresponding objects!}   *)

open ApiTypes

(* ************************************************************************** *)
(** {3 Type}                                                                  *)
(* ************************************************************************** *)

type t =
    {
      info          : Info.t;
      vote          : Vote.t;
      author        : ApiUser.t;
      content       : string;
    }

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

val get : string -> ?page:Page.parameters -> id -> t Page.t Api.t
val create : string -> content:string -> id -> t Api.t
val edit : content:string -> id -> t Api.t
val delete : id -> unit Api.t

(** {6 Vote}                                                                  *)

val vote : id -> Vote.vote -> unit Api.t
val cancel_vote : id -> unit Api.t

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val from_json : Yojson.Basic.json -> t
