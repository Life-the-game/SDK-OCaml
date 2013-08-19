(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** Users API methods                                                         *)

open ApiTypes

(* ************************************************************************** *)
(** {3 Type}                                                                  *)
(* ************************************************************************** *)

type t =
    {
      info                     : Info.t;
      login                    : login;
      firstname                : string option;
      lastname                 : string option;
      name                     : string option;
      avatar                   : ApiMedia.Picture.t option;
      gender                   : Gender.t;
      birthday                 : Date.t option;
      lang                     : Lang.t;
(* PRIVATE *)
      email                    : email option;
(* /PRIVATE *)
      score                    : int;
      level                    : int;
      in_game_network          : bool option;
      game_network_total       : int;
      other_game_network_total : int;
      url                      : url;
    }

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

z(** Get users                                                                *)
val get :
  auth:auth
  -> term:string list
  -> ?page:Page.parameters
  -> ?with_avatar: bool option
  -> ?genders: Gender.t list
  -> ?lang: Lang.t list
  -> ?min_score: int option
  -> ?max_score: int option
  -> ?min_level: int option
  -> ?max_level: int option
  -> ?is_in_network: bool option
  -> unit -> t Page.t Api.t

(** Get a user                                                               *)
val get_one : ?auth:auth option -> id -> t Api.t

(** Create a user                                                            *)
val create :
  login:login
  -> password:string
  -> email:email
  -> lang:Lang.t
  -> ?firstname:string
  -> ?lastname:string
  -> ?gender:Gender.t
  -> ?birthday:Date.t option
  -> ?avatar:path
  -> unit -> t Api.t

(* (\** Delete a user                                                             *\) *)
(* val delete : auth:auth -> id -> unit Api.t *)

(* (\** Edit (put) a user                                                         *\) *)
(* val edit : *)
(*   auth:auth *)
(*   -> ?email:email option *)
(*   -> ?password:password option *)
(*   -> ?firstname:string option *)
(*   -> ?lastname:string option *)
(*   -> ?gender:Gender.t option *)
(*   -> ?birthday:Date.t option *)
(*   -> id -> t Api.t *)

(* (\** Get user's friends                                                        *\) *)
(* val get_friends : *)
(*   ?auth:auth option -> ?lang:Lang.t option *)
(*   -> ?index:int option -> ?limit:int option *)
(*   -> id -> t Page.t Api.t *)

(* (\** The authenticated user request a friendship with a user. *)
(*     {i Note: The src_user is for administrative purpose only}                 *\) *)
(* val be_friend_with : *)
(*   auth:auth -> ?src_user:id option -> id -> unit Api.t *)

(* (\** The authenticated user delete a friendship with a user                    *\) *)
(* val dont_be_friend_with : auth:auth -> id -> unit Api.t *)

(* (\** Delete a friendship between a user and another user *)
(*     {ul {li The first id is the user who own the list} *)
(*         {li The second id is the user in the list}} *)
(*     {i Note: This method is for administrative purpose only}                  *\) *)
(* val delete_friendship : auth:auth -> id -> id -> unit Api.t *)

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val from_json : Yojson.Basic.json -> t
