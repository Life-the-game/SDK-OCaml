(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)

open ApiTypes
open Network

(* ************************************************************************** *)
(* Type                                                                       *)
(* ************************************************************************** *)

type user_activity =
  | NetworkAddition     of ApiUser.t
  | NewMedia            of (ApiAchievementStatus.t * ApiMedia.t list)
  | AchievementUnlocked of ApiAchievementStatus.t
  | NewObjective        of ApiAchievementStatus.t
  | LevelReached        of int
  | Other               of (string
			    * ApiUser.t list
			    * ApiAchievementStatus.t list
			    * ApiMedia.t list
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
(* Tools                                                                      *)
(* ************************************************************************** *)

exception InvalidList of string

let user_from_json c =
  let open Yojson.Basic.Util in

  let users = ("users", ApiTypes.convert_each (c |> member "users") ApiUser.from_json)
  and achievement_statuses : (string * ApiAchievementStatus.t list) =
    ("achievement_status",
     ApiTypes.convert_each (c |> member "achievement_statuses") ApiAchievementStatus.from_json)
  and medias = ("medias", ApiTypes.convert_each (c |> member "medias") ApiMedia.from_json)

  and get_list (_, l) = l

  and get_first (name, l) = try List.hd l
    with _ -> raise (InvalidList ("Empty list of " ^ name))

  (* and get_nth n (name, l) = try List.nth l n *)
  (*   with _ -> raise (InvalidList ("Not enough element in list " ^ name)) *)
  in

  let stype = c |> member "type" |> to_string in
  let other stype =
    Other (stype, get_list users, get_list achievement_statuses,
	   get_list medias,
	   c |> member "data" |> to_string_option) in
  {
    info = Info.from_json c;
    owner = ApiUser.from_json (c |> member "owner");
    template = "not_implemented";
    stype = stype;
    activity =  try (match stype with
      | "new_media" -> NewMedia (get_first achievement_statuses,
      				 get_list medias)

      | "achievement_unlocked" -> AchievementUnlocked
      	(get_first achievement_statuses)

      | "new_objective" -> NewObjective (get_first achievement_statuses)

      | "level_reached" -> LevelReached (c |> member "data" |> to_int)

      | "new_following" -> NetworkAddition (get_first users)

      | stype -> other stype
    ) with InvalidList l -> Failure (l, other "failure")
  }

(* ************************************************************************** *)
(* API Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get User activities                                                        *)
(* ************************************************************************** *)

let user ?(page = Page.default_parameters) ?(owner = "") ?(feed = "") () =
  Api.go
    ~path:["player_activities"]
    ~page:(Some page)
    ~get:(Network.empty_filter [
      ("owner", owner);
      ("feed", feed)
    ])
    (Page.from_json user_from_json)

(* ************************************************************************** *)
(* Get feed                                                                   *)
(* ************************************************************************** *)

let following ?(page = Page.default_parameters) () =
  user ~page:page ~feed:"following" ()

let hot ?(page = Page.default_parameters) () =
  user ~page:page ~feed:"hot" ()


(* ************************************************************************** *)
(* Delete user activity                                                       *)
(* ************************************************************************** *)

let delete_user id =
  Api.go
    ~path:["user_activities"; id_to_string id]
    ~rtype:DELETE
    ~auth_required:true
    Api.noop
