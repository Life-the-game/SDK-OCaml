(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: nox                                                                *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** User's commenting API methods                                             *)

open ApiTypes

(* ************************************************************************** *)
(** {Type}                                                                    *)
(* ************************************************************************** *)

type t =
    {
      info          : Info.t;
      author        : ApiUser.t;
      content       : string;
      medias        : ApiMedia.t list;
    }

(* ************************************************************************** *)
(** {API Methods}                                                             *)
(* ************************************************************************** *)

(* Get comments on an achievement status                                      *)
val get :
    req:requirements
    -> ?page:Page.parameters
(* PRIVATE *)
     -> ?user:id option
(* /PRIVATE *)
     -> ?with_medias:bool option 
     -> id -> t ApiTypes.Page.t Api.t 

(* Get one specific comment on an achievement status                          *)
 val get_comment :
     req:requirements
(* PRIVATE *)
    -> ?user:id option
(* /PRIVATE *)
     -> id -> id -> t Api.t 

(* Create a comment on an achievement status                                  *)
 val create :
     auth:auth
(* PRIVATE *)
     -> author:string
(* /PRIVATE *)
     -> content:string
     -> ?medias:path list
     -> id -> t Api.t 

(* Approve a comment on an achievement status                                 *)
val approve :
    auth:auth
(* PRIVATE *)
    -> approver:string
(* /PRIVATE *)
    -> id -> id -> unit Api.t

(* Disapprove a comment on an achievement status                              *)
val disapprove :
    auth:auth
(* PRIVATE *)
    -> disapprover:id
(* /PRIVATE *)
    -> id -> id -> unit Api.t



(* ************************************************************************** *)
(** {Tools}                                                                   *)
(* ************************************************************************** *)

val from_json : Yojson.Basic.json -> t
