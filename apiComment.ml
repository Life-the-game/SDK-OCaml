(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Elements for commenting                                       *)
(* Author: nox                                                                *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/SDK-OCaml   *)
(* ************************************************************************** *)

open ApiTypes
open Network

(* ************************************************************************** *)
(* Types                                                                      *)
(* ************************************************************************** *)

type t =
    {
      info          : Info.t;
      creator       : ApiUser.t;
      content       : string;
      likers_count  : int;
    }

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

(* Take a json tree representing a comment element                            *)
(* and return a comment element                                               *)
let from_json c =
    let open Yojson.Basic.Util in
    {
        info         = Info.from_json c;
        creator      = ApiUser.from_json (c |> member "creator");
        content      = c |> member "content" |> to_string;
        likers_count = c |> member "likers_count" |> to_int;
    }

(* (\* ************************************************************************** *\) *)
(* (\* Api Methods                                                                *\) *)
(* (\* ************************************************************************** *\) *)

(* (\* ************************************************************************** *\) *)
(* (\* Get comments on an achievement status                                      *\) *)
(* (\* ************************************************************************** *\) *)

(* let get ~auth ?(index = None) ?(limit = None) id = *)
(*     let url = Api.url ~parents:["achievement_statuses"; id ; "comments"] *)
(*     ~get:(Api.pager index limit []) ~auth:(Some auth) () in *)
(*     Api.go ~auth:(Some auth) url (ApiTypes.List.from_json from_json) *)

(* (\* ************************************************************************** *\) *)
(* (\* Comments an achievement status                                             *\) *)
(* (\* ************************************************************************** *\) *)

(* let comment ~auth ?(user_id = None) ?(comment = None) id = *)
(*     let url = Api.url ~parents:["achievement_statuses"; id; "comments"] *)
(*     ~auth:(Some auth) () in *)
(*     Api.go ~auth:(Some auth) ~rtype:POST *)
(*     ~post:(PostList (Api.option_filter *)
(*         [("src_user_id", user_id); *)
(*         ("comment", comment); *)
(*     ])) url from_json *)

(* (\* ************************************************************************** *\) *)
(* (\* Get a comment on an achievement status                                     *\) *)
(* (\* ************************************************************************** *\) *)

(* let get_comment ~auth comment_id id = *)
(*     let url = Api.url ~parents:["achievement_statuses"; id; "comments"; *)
(*     comment_id] ~auth:(Some auth) () in *)
(*     Api.go ~auth:(Some auth) url from_json *)

(* (\* ************************************************************************** *\) *)
(* (\* Edit (put) a comment on an achievement status                              *\) *)
(* (\* ************************************************************************** *\) *)

(* let edit ~auth ?(comment = None) comment_id id = *)
(*     let url = Api.url ~parents:["achievement_statuses"; id; "comments"; *)
(*     comment_id] ~auth:(Some auth) () in *)
(*     Api.go ~auth:(Some auth) ~rtype:PUT ~post:(PostList (Api.option_filter *)
(*         [("comment", comment)])) url from_json *)

(* (\* ************************************************************************** *\) *)
(* (\* Remove a comment from an achievement status                                *\) *)
(* (\* ************************************************************************** *\) *)

(* let remove ~auth comment_id id = *)
(*     let url = Api.url ~parents:["achievement_statuses"; id; "comments"; *)
(*     comment_id] ~auth:(Some auth) () in *)
(*     Api.noop ~auth:(Some auth) ~rtype:DELETE url *)

(* (\* ************************************************************************** *\) *)
(* (\* Get likers for a comment                                                   *\) *)
(* (\* ************************************************************************** *\) *)

(* let get_likers ~auth ?(index = None) ?(limit = None) comment_id id = *)
(*     let url = Api.url ~parents:["achievement_statuses"; id; "comments"; *)
(*     comment_id; "likers"] ~get:(Api.pager index limit []) ~auth:(Some auth) () in *)
(*     Api.go ~auth:(Some auth) url (ApiTypes.List.from_json from_json) *)

(* (\* ************************************************************************** *\) *)
(* (\* Like a comment                                                             *\) *)
(* (\* ************************************************************************** *\) *)

(* let like ~auth ?(user_id = None) comment_id id = *)
(*     let url = Api.url ~parents:["achievement_statuses"; id; "comments"; *)
(*     comment_id; "likers"] *)
(*     ~auth:(Some auth) () in *)
(*     Api.noop ~auth:(Some auth) ~rtype:POST ~post:(PostList (Api.option_filter *)
(*     [("src_user_id", user_id)])) url *)

(* (\* ************************************************************************** *\) *)
(* (\* Remove a like from a comment                                               *\) *)
(* (\* ************************************************************************** *\) *)

(* let remove_like ~auth comment_id id = *)
(*     let url = Api.url ~parents:["achievement_statuses"; id; "comments"; *)
(*     comment_id; "likers"] ~auth:(Some auth) () in *)
(*     Api.noop ~auth:(Some auth) ~rtype:DELETE url *)

(* (\* ************************************************************************** *\) *)
(* (\* Remove a liker from a comment                                              *\) *)
(* (\* ************************************************************************** *\) *)

(* let remove_liker ~auth user_id comment_id id = *)
(*     let url = Api.url ~parents:["achievement_statuses"; id; "comments"; *)
(*     comment_id; "likers"; user_id] ~auth:(Some auth) () in *)
(*     Api.noop ~auth:(Some auth) ~rtype:DELETE url *)






