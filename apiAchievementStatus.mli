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
      approvement      : Approvable.t;
      owner            : ApiUser.t;
      achievement      : ApiAchievement.t;
      status           : Status.t;
      message          : string option;
      medias           : ApiMedia.t list;
      nb_comments      : int;
      url              : url;
    }

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

(** Search achievement statuses                                               *)
val search :
  req:requirements
  -> ?page:Page.parameters
  -> ?owner:string
  -> ?nb_comments:bool
  -> ?achievement:string
  -> ?status:Status.t option
  -> unit -> t ApiTypes.Page.t Api.t

(** Get achievement statuses                                                  *)
val get :
  req:requirements
  -> ?page:Page.parameters
  -> ?term: string list
  -> ?nb_comments:bool
  -> ?achievements: id list
  -> ?with_medias: bool option
  -> ?status:Status.t option
  -> id -> t ApiTypes.Page.t Api.t

(** Get one achievement status                                                *)
val get_one :
  req:requirements
  -> ?nb_comments:bool
  -> id -> t Api.t

(** Create an achievement status                                              *)
val create :
  auth:auth
  -> achievement:id
  -> status:Status.t
(* PRIVATE *)
  -> ?user: id option
(* /PRIVATE *)
  -> ?message:string
  -> ?medias:file list
  -> unit -> t Api.t

(** Edit an achievement status                                                *)
val edit :
  auth:auth
  -> ?status:Status.t option
  -> ?message:string option
  -> ?add_medias:file list
  -> ?remove_medias:id list
  -> id -> t Api.t

(** Approve an achievement status                                             *)
val approve :
  auth:auth
(* PRIVATE *)
  -> approver: id
(* /PRIVATE *)
  -> id -> unit Api.t

(** Disapprove an achievement status                                          *)
val disapprove :
  auth:auth
(* PRIVATE *)
  -> disapprover: id
(* /PRIVATE *)
  -> id -> unit Api.t


(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val from_json : ?nb_comments:bool -> Yojson.Basic.json -> t
