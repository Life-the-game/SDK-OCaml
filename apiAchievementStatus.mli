(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** Achievement statuses API methods                                          *)

open ApiTypes

(* ************************************************************************** *)
(** {3 Type}                                                                  *)
(* ************************************************************************** *)

type t =
    {
      info             : Info.t;
      vote             : Vote.t;
      owner            : ApiUser.t;
      achievement      : ApiAchievement.t;
      status           : Status.t;
      message          : string;
      mutable medias   : media list;
      total_comments   : int;
      url              : url;
    }

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

val get :
  session:session
  -> ?page:Page.parameters
  -> ?owners: login list
  -> ?achievements: id list
  -> ?statuses:Status.t list
  -> ?terms: string list
  -> ?with_medias: bool option
  -> unit -> t ApiTypes.Page.t Api.t

val get_one : session:session -> id -> t Api.t

val create :
  session:session
  -> achievement:id
  -> status:Status.t
  -> ?message:string
  -> unit -> t Api.t

val edit :
  session:session
  -> ?status:Status.t option
  -> ?message:string
  -> id -> t Api.t

val delete :
  session:session
  -> id -> unit Api.t

(** {6 Medias}                                                                *)

val add_media :
  session:session
  -> either_file -> id -> media Api.t
val delete_media :
  session:session
  -> id -> unit Api.t

(** {6 Vote}                                                                  *)

val vote :
  session:session
  -> id -> Vote.vote -> unit Api.t
val cancel_vote :
  session:session
  -> id -> unit Api.t

(** {6 Comments}                                                              *)

val comments       :
  session:session
  -> ?page: Page.parameters -> id -> ApiComment.t Page.t Api.t
val add_comment    :
  session:session
  -> content:string -> id -> ApiComment.t Api.t
val edit_comment   :
  session:session
  -> content:string -> id -> ApiComment.t Api.t
val delete_comment :
  session:session
  -> id -> unit Api.t
val vote_comment   :
  session:session
  -> id -> Vote.vote -> unit Api.t
val cancel_vote_comment :
  session:session
  -> id -> unit Api.t

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val from_json : Yojson.Basic.json -> t
