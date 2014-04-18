(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: nox                                                                *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** User's commenting API methods                                             *)

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

(** Edit a comment *)
val edit : content:string -> id -> t Api.t

(** Delete a comment *)
val delete : id -> unit Api.t

(** Vote *)
val vote : Vote.vote -> id -> t Api.t
val cancel_vote : id -> t Api.t

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val from_json : Yojson.Basic.json -> t
