(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** Activities API methods                                                    *)

open ApiTypes

(* ************************************************************************** *)
(** {3 Type}                                                                  *)
(* ************************************************************************** *)

type user_activity =
  | NetworkAddition     of ApiUser.t
  | NewMedia            of (ApiAchievementStatus.t * media list)
  | AchievementUnlocked of ApiAchievementStatus.t
  | NewObjective        of ApiAchievementStatus.t
  | LevelReached        of int
  | Other               of (string
			    * ApiUser.t list
			    * ApiAchievementStatus.t list
			    * media list
			    * string option)
  | Failure             of (string * user_activity)

type ('a, 'b) t = {
  info : Info.t;
  owner : 'a;
  stype : string;
  template : string;
  activity : 'b;
}

type user = (ApiUser.t, user_activity) t

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

(** Get user activities                                                       *)
val user :
  session:session
  -> ?page:Page.parameters
  -> ?owner:login
  -> ?feed:string
  -> unit -> user Page.t Api.t

(** Get feed *)
val following :
  session:session
  -> ?page:Page.parameters -> unit -> user Page.t Api.t 
val hot :
  session:session
  -> ?page:Page.parameters -> unit -> user Page.t Api.t 

(** Delete user activities *)
val delete_user :
  session:session
  -> id -> unit Api.t

(** Notifications *)
val notifications : session:session -> unit -> notification Page.t Api.t
val mark_read : session:session -> id -> notification Api.t
val mark_unread : session:session -> id -> notification Api.t

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val user_from_json : Yojson.Basic.json -> user
