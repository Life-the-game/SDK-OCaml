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

module type STATUS =
sig
  type t =
    | Objective
    | Achieved
  val to_string : t -> string
  val of_string : string -> t
end
module Status : STATUS

type t =
    {
      info             : Info.t;
      approvement      : Approvable.t;
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

(** Get achievement statuses                                                  *)
val get :
  req:requirements
  -> ?page:Page.parameters
  -> ?term: string list
  -> ?achievements: id list
  -> ?with_medias: bool option
  -> ?status:Status.t option
  -> id -> t ApiTypes.Page.t Api.t

(** Get one achievement status                                                *)
val get_one :
  req:requirements
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
  -> ?medias:path list
  -> unit -> t Api.t

(** Edit an achievement status                                                *)
val edit :
  auth:auth
  -> ?status:Status.t option
  -> ?message:string option
  -> ?add_medias:path list
  -> ?remove_medias:id list
  -> id -> t Api.t

(** Approve an achievement status                                             *)
val approve :
  auth:auth
(* PRIVATE *)
  -> approver: id option
(* /PRIVATE *)
  -> id -> unit Api.t

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val from_json : Yojson.Basic.json -> t
