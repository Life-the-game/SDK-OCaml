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
    medias           = ApiTypes.convert_each (c |> member "medias") ApiMedia.from_json;
    url              = c |> member "url" |> to_string;
  }

(* ************************************************************************** *)
(* API Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Search achievement statuses                                                *)
(* ************************************************************************** *)

let search ~req ?(page = Page.default_parameters) ?(owner = "")
    ?(achievement = "") ?(status = (None : ApiTypes.Status.t option)) () =
  Api.go
    ~path:["achievement_statuses"]
    ~req:(Some req)
    ~page:(Some page)
    ~get:(Network.option_filter [
      ("owner", Some owner);
      ("achievement", Some achievement);
      ("status", Option.map Status.to_string status);
    ])
    (Page.from_json from_json)

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

let get_one ~req achievement_id =
  Api.go
    ~path:["achievement_statuses"; achievement_id]
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
      ApiMedia.checker)
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
       ApiMedia.checker) in
  Api.go
    ~rtype:PUT
    ~path:(["achievement_statuses"; id])
    ~req:(Some (Auth auth))
    ~post:post
    from_json

(* ************************************************************************** *)
(* Approve an achievement status                                              *)
(* ************************************************************************** *)

let approve ~auth
(* PRIVATE *)
    ~approver
(* /PRIVATE *)
    id =
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
        ~path:(["achievement_statuses"; id; "approvers"])
        ~req:(Some (Auth auth))
        ~post:post
        Api.noop

(* ************************************************************************** *)
(* Disapprove an achievement status                                           *)
(* ************************************************************************** *)

let disapprove ~auth
(* PRIVATE *)
    ~disapprover
(* /PRIVATE *)
    id =
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
        ~path:(["achievement_statuses"; id; "disapprovers"])
        ~req:(Some (Auth auth))
        ~post:post
        Api.noop

