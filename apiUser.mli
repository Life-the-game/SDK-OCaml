(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools to get/edit users                                       *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

open ApiTypes

(* ************************************************************************** *)
(** Types                                                                     *)
(* ************************************************************************** *)

type t =
    {
      info               : Info.t;
      login              : login;
      firstname          : string;
      lastname           : string;
      avatar             : ApiMedia.Picture.t option;
      gender             : Gender.t;
      birthday           : Date.t;
      is_friend          : bool option;
      url                : url;
      lang               : Lang.t;
    }

(* ************************************************************************** *)
(** Api Methods                                                               *)
(* ************************************************************************** *)

(** Create a user                                                             *)
val create :
  login:login
  -> email:email
  -> password:string
  -> lang:Lang.t
  -> ?firstname:string option
  -> ?lastname:string option
  -> ?gender:Gender.t option
  -> ?birthday:Date.t option
  -> unit -> t Api.t

(** Get users                                                                 *)
val get :
  auth:auth
  -> ?term:string option
  -> ?index:int option
  -> ?limit:int option
  -> unit -> t ApiTypes.List.t Api.t

(** Get a user                                                                *)
val get_user : ?auth:auth option -> ?lang:Lang.t option -> id -> t Api.t

(** Delete a user                                                             *)
val delete : auth:auth -> id -> unit Api.t

(** Edit (put) a user                                                         *)
val edit :
  auth:auth
  -> ?email:email option
  -> ?password:password option
  -> ?firstname:string option
  -> ?lastname:string option
  -> ?gender:Gender.t option
  -> ?birthday:Date.t option
  -> id -> t Api.t

(** Get user's friends                                                        *)
val get_friends :
  ?auth:auth option -> ?lang:Lang.t option
  -> ?index:int option -> ?limit:int option
  -> id -> t ApiTypes.List.t Api.t

(** The authenticated user request a friendship with a user                   *)
(**   Note: The src_user is for administrative purpose only                   *)
val be_friend_with :
  auth:auth -> ?src_user:id option -> id -> unit Api.t

(** The authenticated user delete a friendship with a user                    *)
val dont_be_friend_with : auth:auth -> id -> unit Api.t

(** Delete a friendship between a user and another user                       *)
(** The first id is the user who own the list                                 *)
(** The second id is the user in the list                                     *)
(**   Note: This method is for administrative purpose only                    *)
val delete_friendship : auth:auth -> id -> id -> unit Api.t

(* ************************************************************************** *)
(** Tools                                                                     *)
(* ************************************************************************** *)

(** Take a json tree representing a user and return an object user            *)
val from_json : Yojson.Basic.json -> t