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
  | NewFollowing        of ApiUser.t
  | NewFollower         of ApiUser.t
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

type notification = {
  infos : Info.t;
  stype : string;
  read : bool;
  players : ApiUser.t list;
  achievements : ApiAchievement.t list;
  achievement_statuses : ApiAchievementStatus.t list;
  comments : ApiComment.t list;
  data : string;
}

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

exception InvalidList of string

let user_from_json c =
  let open Yojson.Basic.Util in

  let users = ("users", ApiTypes.convert_each (c |> member "players") ApiUser.from_json)
  and achievement_statuses : (string * ApiAchievementStatus.t list) =
    ("achievement_status",
     ApiTypes.convert_each (c |> member "achievement_statuses") ApiAchievementStatus.from_json)
  and medias = ("medias", ApiTypes.convert_each (c |> member "medias") media_from_json)

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

      | "new_follower" -> NewFollower (get_first users)

      | "new_following" -> NewFollowing (get_first users)

      | stype -> other stype
    ) with InvalidList l -> Failure (l, other "failure")
  }

let notification_from_json c =
  let open Yojson.Basic.Util in {
    infos = Info.from_json c;
    stype =  c |> member "type" |> to_string;
    read = c |> member "read" |> to_bool;
    players = ApiTypes.convert_each (c |> member "players") ApiUser.from_json;
    achievements = ApiTypes.convert_each (c |> member "achievements") ApiAchievement.from_json;
    achievement_statuses = ApiTypes.convert_each (c |> member "achievement_statuses") ApiAchievementStatus.from_json;
    comments = ApiTypes.convert_each (c |> member "comments") ApiComment.from_json;
    data = c |> member "data" |> ApiTypes.to_string_option;
  }

(* ************************************************************************** *)
(* API Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get User activities                                                        *)
(* ************************************************************************** *)

let user ~session ?(page = Page.default_parameters) ?(owner = "") ?(feed = "") () =
  Api.go
    ~session:session
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

let following ~session?(page = Page.default_parameters) () =
  user ~session ~page:page ~feed:"following" ()

let hot ~session ?(page = Page.default_parameters) () =
  user ~session:session ~page:page ~feed:"hot" ()

(* ************************************************************************** *)
(* Delete user activity                                                       *)
(* ************************************************************************** *)

let delete_user ~session id =
  Api.go
    ~session:session
    ~path:["user_activities"; id_to_string id]
    ~rtype:DELETE
    ~auth_required:true
    Api.noop

(* ************************************************************************** *)
(* Notifications                                                              *)
(* ************************************************************************** *)

let notifications ~session ?(page = Page.default_parameters) () =
  Api.go
    ~session:session
    ~path:["notifications"]
    ~page:(Some page)
    ~auth_required:true
    (Page.from_json notification_from_json)

let mark_read ~session id =
  Api.go
    ~session:session
    ~path:["notifications"; id_to_string id; "read"]
    ~auth_required:true
    notification_from_json

let mark_unread ~session id =
  Api.go
    ~session:session
    ~path:["notifications"; id_to_string id; "unread"]
    ~auth_required:true
    notification_from_json
