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

module type STATUS =
sig
  type t =
    | Objective
    | Achieved
  val to_string : t -> string
  val of_string : string -> t
end
module Status : STATUS =
struct
  type t =
    | Objective
    | Achieved
  let to_string = function (* todo: update the api to use the correct words *)
    | Objective -> "planned"
    | Achieved  -> "done"
  let of_string = function
    | "planned" -> Objective
    | "done"    -> Achieved
    | _         -> Objective
end

type t =
    {
      info             : Info.t;
      approvement      : Approvable.t;
      owner            : ApiUser.t;
      achievement      : ApiAchievement.t;
      status           : Status.t;
      message          : string option;
      medias           : ApiMedia.t list;
      url              : url;
    }

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

let from_json c =
  let open Yojson.Basic.Util in
      {
        info        = Info.from_json c;
        approvement      = Approvable.from_json c;
        owner            = ApiUser.from_json (c |> member "owner");
        achievement      = ApiAchievement.from_json (c |> member "achievement");
        status           = Status.of_string (c |> member "status" |> to_string);
        message          = c |> member "message" |> to_string_option;
        medias           = c |> member "medias" |>
            convert_each ApiMedia.from_json;
        url              = c |> member "url" |> to_string;
      }

(* ************************************************************************** *)
(* API Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get achievement statuses                                                   *)
(* ************************************************************************** *)

let get ~req ?(page = Page.default_parameters) ?(term = [])
    ?(achievements = []) ?(with_medias = None)
    ?(status = None) id =
  Api.go
    ~path:["users"; id; "achievement_statuses"]
    ~req:(Some req)
    ~page:(Some page)
    ~get:(Network.option_filter
            [("term", Some (Network.list_parameter term));
             ("achievements", Some (Network.list_parameter achievements));
             ("with_medias", Option.map string_of_bool with_medias);
             ("status", Option.map Status.to_string status);
            ])
    (Page.from_json from_json)

(* ************************************************************************** *)
(* Get one achievement status                                                 *)
(* ************************************************************************** *)

let get_one ~req user_id achievement_id =
  Api.go
    ~path:["users"; user_id; "achievement_status"; achievement_id]
    ~req:(Some req)
    from_json

(* ************************************************************************** *)
(* Create an achievement status                                               *)
(* ************************************************************************** *)

let create ~auth ~achievement ~status
(* PRIVATE *)
    ?(user = None)
(* /PRIVATE *)
    ?(message = "") ?(medias = []) () =
  let post_parameters =
    Network.empty_filter
      [("achievement_id", achievement);
       ("status",         Status.to_string status);
       ("message",        message);
      ] in
  let post = if List.length medias != 0
    then Network.PostMultiPart
      (post_parameters,
       (List.map (fun media -> ("medias", media)) medias),
      ApiMedia.path_to_contenttype)
    else Network.PostList post_parameters in
  Api.go
    ~rtype:POST
    ~path:(
(* PRIVATE *)
    (match user with
      | Some user_id -> ["users"; user_id]
      | None         -> []) @
(* /PRIVATE *)
      ["achievement_statuses"])
    ~req:(Some (Auth auth))
    ~post:post
    from_json

(* ************************************************************************** *)
(* Edit an achievement status                                                 *)
(* ************************************************************************** *)

let edit ~auth
(* PRIVATE *)
    ?(user = None)
(* /PRIVATE *)
    ?(status = None)
    ?(message = None)
    ?(add_medias = [])
    ?(remove_medias = [])
    id =
  let post_parameters =
    (Network.option_filter
       [("status", Option.map Status.to_string status);
        ("remove_medias", Some (Network.list_parameter remove_medias));
       ]) @ (match message with Some m -> [("message", m)] | None -> []) in
  let post =
    Network.PostMultiPart
      (post_parameters,
       (Network.multiple_files "medias" add_medias),
       ApiMedia.path_to_contenttype) in
  Api.go
    ~rtype:PUT
    ~path:(
(* PRIVATE *)
    (match user with
      | Some user_id -> ["users"; user_id]
      | None         -> []) @
(* /PRIVATE *)
      ["achievement_statuses"; id])
    ~req:(Some (Auth auth))
    ~post:post
    from_json

(* (\* ************************************************************************** *\) *)
(* (\* Delete an achievement status                                               *\) *)
(* (\* ************************************************************************** *\) *)

(* let delete ~auth user_id as_id = *)
(*     let url = Api.url ~parents:["user"; user_id; "achievement_statuses"; as_id] *)
(*         ~auth:(Some auth) () in *)
(*     Api.noop ~auth:(Some auth) ~rtype:DELETE url *)

(* (\* ************************************************************************** *\) *)
(* (\* Get the details of one achievement status                                  *\) *)
(* (\* ************************************************************************** *\) *)

(* let get_one ~auth id = *)
(*   let url = Api.url ~parents:["achievement_statuses"; id] *)
(*     ~auth:(Some auth) () in *)
(*   Api.go ~auth:(Some auth) url from_json *)

(* (\* ************************************************************************** *\) *)
(* (\* Delete user's achievement status                                           *\) *)
(* (\* ************************************************************************** *\) *)

(* let delete ~auth id = *)
(*   let url = Api.url ~parents:["achievement_statuses"; id] ~auth:(Some auth) () in *)
(*   Api.noop ~auth:(Some auth) ~rtype:DELETE url *)

(* (\* ************************************************************************** *\) *)
(* (\* Get approvers for an achievement status                                    *\) *)
(* (\* ************************************************************************** *\) *)

(* let get_approvers ~auth ?(index = None) ?(limit = None) id = *)
(*     let url = Api.url ~parents:["achievement_statuses"; id; "approvers"]  *)
(*         ~auth:(Some auth) *)
(*         ~get:(Api.pager index limit []) () in *)
(*     Api.go ~auth:(Some auth) url (List.from_json from_json) *)

(* (\* ************************************************************************** *\) *)
(* (\* Approve an achievement status                                              *\) *)
(* (\* ************************************************************************** *\) *)

(* let approve ~auth ?(src_user = None) id = *)
(*     let url = *)
(*         Api.url ~parents:["achievement_statuses"; id; "approvers"] ~auth:(Some *)
(*         auth) () in *)
(*     Api.noop ~auth:(Some auth) ~rtype:POST *)
(*         ~post:(PostList (Api.option_filter [("src_user_id", src_user)])) url *)

(* (\* ************************************************************************** *\) *)
(* (\* Remove approving from an achievement status                                *\) *)
(* (\* ************************************************************************** *\) *)

(* let remove_approve ~auth id = *)
(*     let url = Api.url ~parents:["achievement_statuses"; id; "approvers"] ~auth:(Some *)
(*         auth) () in *)
(*     Api.noop ~auth:(Some auth) ~rtype:DELETE url *)

(* (\* ************************************************************************** *\) *)
(* (\* Remove an approver from an achievement status                              *\) *)
(* (\* ************************************************************************** *\) *)

(* let remove_approver ~auth as_id user_id = *)
(*     let url = Api.url ~parents:["achievement_statuses"; as_id; "approvers"; *)
(*         user_id] ~auth:(Some auth) () in *)
(*     Api.noop ~auth:(Some auth) ~rtype:DELETE url *)


(* (\* ************************************************************************** *\) *)
(* (\* Get disapprovers for an achievement status                                 *\) *)
(* (\* ************************************************************************** *\) *)

(* let get_disapprovers ~auth ?(index = None) ?(limit = None) id = *)
(*     let url = Api.url ~parents:["achievement_statuses"; id; "disapprovers"]  *)
(*         ~auth:(Some auth) *)
(*         ~get:(Api.pager index limit []) () in *)
(*     Api.go ~auth:(Some auth) url (List.from_json from_json) *)

(* (\* ************************************************************************** *\) *)
(* (\* Disapprove an achievement status                                           *\) *)
(* (\* ************************************************************************** *\) *)

(* let disapprove ~auth ?(src_user = None) id = *)
(*     let url = *)
(*         Api.url ~parents:["achievement_statuses"; id; "disapprovers"] ~auth:(Some *)
(*         auth) () in *)
(*     Api.noop ~auth:(Some auth) ~rtype:POST *)
(*         ~post:(PostList (Api.option_filter [("src_user_id", src_user)])) url *)

(* (\* ************************************************************************** *\) *)
(* (\* Remove disapproving from an achievement status                             *\) *)
(* (\* ************************************************************************** *\) *)

(* let remove_disapprove ~auth id = *)
(*     let url = Api.url ~parents:["achievement_statuses"; id; "disapprovers"] *)
(*     ~auth:(Some *)
(*         auth) () in *)
(*     Api.noop ~auth:(Some auth) ~rtype:DELETE url *)

(* (\* ************************************************************************** *\) *)
(* (\* Remove a disapprover from an achievement status                            *\) *)
(* (\* ************************************************************************** *\) *)

(* let remove_disapprover ~auth as_id user_id = *)
(*     let url = Api.url ~parents:["achievement_statuses"; as_id; "disapprovers"; *)
(*         user_id] ~auth:(Some auth) () in *)
(*     Api.noop ~auth:(Some auth) ~rtype:DELETE url *)

