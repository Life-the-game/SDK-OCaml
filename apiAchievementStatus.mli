(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/SDK-OCaml   *)
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
  -> ?status:Status.t option
  -> id -> t ApiTypes.Page.t Api.t

(** Get one achievement status                                                *)
val get_one :
  req:requirements
  -> id -> id -> t Api.t
(** The first id is the user_id, the second is the achievement status id      *)

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
(* PRIVATE *)
  -> ?user: id option
(* /PRIVATE *)
  -> ?status:Status.t option
  -> ?message:string option
  -> ?add_medias:path list
  -> ?remove_medias:id list
  -> id -> t Api.t

(* (\** Delete an achievement status                                            *\) *)
(* val delete : *)
(*     auth:auth -> id -> id -> unit Api.t *)

(* (\** Delete user's achievement status                                        *\) *)
(* val delete : *)
(*     auth:auth -> id -> unit Api.t *)

(* (\** Edit (put) an achievement status                                        *\) *)
(* val edit : *)
(*     auth:auth *)
(*     -> ?state_code:int option *)
(*     -> ?message:string option *)
(*     -> id -> t Api.t *)

(* (\** Get approvers for an achievement status                                 *\) *)
(* val get_approvers : *)
(*     auth:auth *)
(*     -> ?index:int option *)
(*     -> ?limit:int option *)
(*     -> id -> t List.t Api.t *)

(* (\** Approve an achievement status                                           *\) *)
(* val approve : *)
(*     auth:auth *)
(*     -> ?src_user:id option *)
(*     -> id -> unit Api.t *)

(* (\* Remove approving from an achievement status                              *\) *)
(* val remove_approve : *)
(*     auth:auth -> id -> unit Api.t *)

(* (\* Remove an approver from an achievement status                            *\) *)
(* val remove_approver : *)
(*     auth:auth -> id -> id -> unit Api.t *)

(* (\** Get disapprovers for an achievement status                              *\) *)
(* val get_disapprovers : *)
(*     auth:auth *)
(*     -> ?index:int option *)
(*     -> ?limit:int option *)
(*     -> id -> t List.t Api.t *)

(* (\** Disapprove an achievement status                                        *\) *)
(* val disapprove : *)
(*     auth:auth *)
(*     -> ?src_user:id option *)
(*     -> id -> unit Api.t *)

(* (\* Remove disapproving from an achievement status                           *\) *)
(* val remove_disapprove : *)
(*     auth:auth -> id -> unit Api.t *)

(* (\* Remove a disapprover from an achievement status                          *\) *)
(* val remove_disapprover : *)
(*     auth:auth -> id -> id -> unit Api.t *)


