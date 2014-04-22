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
      comments         : int;
      owner            : ApiUser.t;
      achievement      : ApiAchievement.t;
      status           : Status.t;
      message          : string option;
      medias           : ApiMedia.t list;
      url              : url;
    }

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

val get :
  ?page:Page.parameters
  -> ?owners: login list
  -> ?achievements: id list
  -> ?statuses:Status.t list
  -> ?terms: string list
  -> ?with_medias: bool option
  -> unit -> t ApiTypes.Page.t Api.t

val get_one : id -> t Api.t

val create :
  achievement:id
  -> status:Status.t
  -> ?message:string
  -> ?medias:either_file list
  -> unit -> t Api.t

val edit :
  ?status:Status.t option
  -> ?message:string
  -> ?add_medias:either_file list
  -> ?remove_medias:id list
  -> id -> t Api.t

val delete : id -> unit Api.t

(** {6 Vote}                                                                  *)

val vote : id -> Vote.vote -> t Api.t
val cancel_vote : id -> t Api.t

(** {6 Comments}                                                              *)

val comments       : ?page: Page.parameters -> id -> ApiComment.t Page.t Api.t
val add_comment    : content:string -> id -> ApiComment.t Api.t
val edit_comment   : content:string -> id -> ApiComment.t Api.t
val delete_comment : id -> unit Api.t
val vote_comment   : id -> Vote.vote -> ApiComment.t Api.t
val cancel_vote_comment : id -> ApiComment.t Api.t

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val from_json : Yojson.Basic.json -> t
