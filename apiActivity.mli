(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)
(** Activities API methods                                                    *)

open ApiTypes

(* ************************************************************************** *)
(** {3 Type}                                                                  *)
(* ************************************************************************** *)

type t =
    {
      info          : Info.t;
      activity      : string;
      activity_type : int;
    }

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

(** Get activities                                                            *)
val get :
  ?auth:auth option -> ?lang:Lang.t option
  -> ?index:int option -> ?limit:int option
  -> id -> t ApiTypes.List.t Api.t

(** Delete an activity                                                        *)
val delete :
  auth:auth -> id -> id -> unit Api.t
