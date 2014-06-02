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

val get :
  string -> session:session
  -> ?page:Page.parameters -> id -> t Page.t Api.t
val create :
  string -> session:session
  -> content:string -> id -> t Api.t
val edit :
  session:session
  -> content:string -> id -> t Api.t
val delete :
  session:session
  -> id -> unit Api.t

(** {6 Vote}                                                                  *)

val vote :
  session:session
  -> id -> Vote.vote -> unit Api.t
val cancel_vote :
  session:session
  -> id -> unit Api.t

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val from_json : Yojson.Basic.json -> t
