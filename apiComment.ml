(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: nox                                                                *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)

open ApiTypes
open Network

(* ************************************************************************** *)
(* Type                                                                       *)
(* ************************************************************************** *)

type t =
    {
      info          : Info.t;
      approvement   : Approvable.t;
      author        : ApiUser.t;
      content       : string;
      medias        : ApiMedia.t list;
    }

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

let from_json c =
    let open Yojson.Basic.Util in
    {
        info         = Info.from_json c;
        approvement  = Approvable.from_json c;
        author       = ApiUser.from_json (c |> member "author");
        content      = c |> member "content" |> to_string;
	medias       = ApiTypes.convert_each (c |> member "medias") ApiMedia.from_json;
    }

(* ************************************************************************** *)
(* {API Methods}                                                              *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get comments on an achievement status                                      *)
(* ************************************************************************** *)

let get ?(page = Page.default_parameters) ?(with_medias = None) id =
  Api.go
    ~path:["achievement_statuses"; id; "comments"]
    ~page:(Some page)
    ~get:(Network.option_filter
            [("with_medias", Option.map string_of_bool with_medias);
            ])
    (Page.from_json from_json)

(* ************************************************************************** *)
(* Get one specific comment on an achievement status                          *)
(* ************************************************************************** *)

let get_one achievement_status_id comment_id =
    Api.go
      ~path:["achievement_statuses"; achievement_status_id; "comments"; comment_id]
      from_json

(* ************************************************************************** *)
(* Create a comment on an achievement status                                  *)
(* ************************************************************************** *)
(* PRIVATE *)
(* Note: Only admin can change the author *)
(* /PRIVATE *)

let create ~auth
(* PRIVATE *)
    ?(author = None)
(* /PRIVATE *)
    ?(medias = [])
    ~content
    id =
  let post_parameters =
    Network.option_filter
      [("content", Some content);
(* PRIVATE *)
       ("author", author);
(* /PRIVATE *)
      ] in
  let post = if List.length medias != 0
    then Network.PostMultiPart
      (post_parameters,
       (List.map (fun media -> ("medias", media)) medias),
       ApiMedia.checker)
    else Network.PostList post_parameters in
  Api.go
    ~rtype:POST
    ~path:["achievement_statuses"; id; "comments"]
    ~req:(Some (Auth auth))
    ~post:post
    from_json


(* ************************************************************************** *)
(* Approve a comment on an achievement status                                 *)
(* ************************************************************************** *)

let approve ~auth
(* PRIVATE *)
    ~approver
(* /PRIVATE *)
   comment_id id =
  let post_parameters =
    Network.empty_filter
      [
(* PRIVATE *)
          ("approver", approver);
(* /PRIVATE *)
      ] in
    let post = Network.PostList post_parameters in
  Api.go
    ~rtype:POST
    ~path:(["comments"; comment_id; "approvers"])
    ~req:(Some (Auth auth))
    ~post:post
    Api.noop


(* ************************************************************************** *)
(* Disapprove a comment on an achievement status                              *)
(* ************************************************************************** *)

let disapprove ~auth
(* PRIVATE *)
    ~disapprover
(* /PRIVATE *)
   comment_id id =
  let post_parameters =
    Network.empty_filter
      [
(* PRIVATE *)
          ("disapprover", disapprover);
(* /PRIVATE *)
      ] in
    let post = Network.PostList post_parameters in
  Api.go
    ~rtype:POST
    ~path:(["comments"; comment_id; "disapprovers"])
    ~req:(Some (Auth auth))
    ~post:post
    Api.noop

  
    
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






