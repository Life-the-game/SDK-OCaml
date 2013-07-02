(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)
(** Achievement statuses API methods                                          *)

open ApiTypes

(* ************************************************************************** *)
(** {3 Type}                                                                  *)
(* ************************************************************************** *)

type t =
    {
      info             : Info.t;
      owner            : ApiUser.t;
      achievement      : ApiAchievement.t;
      state            : string;
      state_code       : int;
      message          : string;
      approvers        : ApiUser.t ApiTypes.List.t;
      non_approvers    : ApiUser.t ApiTypes.List.t;
      attached_picture : ApiMedia.Picture.t;
      score            : int;
    }

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

(** Get user's achievement status'                                            *)
val get :
  ?auth:auth option -> ?lang:Lang.t option
  -> ?index:int option -> ?limit:int option
  -> id -> t ApiTypes.List.t Api.t

(** Add a new achievement in a user's listo.
    The upload_picture argument is an optional string wich is the path of
    file corresponding to the picture you would like to upload.             *)
val add :
  auth:auth -> achievement:id -> state_code:int -> message:string
  -> ?upload_picture:string option -> id -> t Api.t
