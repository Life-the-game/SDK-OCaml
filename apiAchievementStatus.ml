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
      vote             : Vote.t;
      comments         : int;
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
    info             = Info.from_json c;
    vote             = Vote.from_json c;
    comments         = c |> member "comments" |> ApiTypes.to_int_option;
    owner            = ApiUser.from_json (c |> member "owner");
    achievement      = ApiAchievement.from_json (c |> member "achievement");
    status           = Status.of_string (c |> member "status" |> to_string);
    message          = c |> member "message" |> to_string_option;
    medias           = ApiTypes.convert_each (c |> member "medias") ApiMedia.from_json;
    url              = c |> member "website_url" |> to_string;
  }

(* ************************************************************************** *)
(* API Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get achievement statuses                                                   *)
(* ************************************************************************** *)

let get ?(page = Page.default_parameters)
    ?(owners = [])
    ?(achievements = [])
    ?(statuses = [])
    ?(terms = [])
    ?(with_medias = None)
    () =
  Api.go
    ~path:["achievement_statuses"]
    ~page:(Some page)
    ~get:(Network.option_filter [
      ("owners", Some (Network.list_parameter owners));
      ("achievements", Some (Network.list_parameter (List.map id_to_string achievements)));
      ("statuses", Some (Network.list_parameter (List.map Status.to_string statuses)));
      ("terms", Some (Network.list_parameter terms));
      ("with_medias", Option.map string_of_bool with_medias);
    ])
    (Page.from_json from_json)

(* ************************************************************************** *)
(* Get one achievement status                                                 *)
(* ************************************************************************** *)

let get_one achievement_id =
  Api.go
    ~path:["achievement_statuses"; id_to_string achievement_id]
    from_json

(* ************************************************************************** *)
(* Create an achievement status                                               *)
(* ************************************************************************** *)

let create ~achievement ~status ?(message = "") () =
  let post_parameters = Network.empty_filter ([
    ("achievement", id_to_string achievement);
    ("status",      Status.to_string status);
    ("message",     message);
  ]) in
  let post = Network.PostList post_parameters in
  Api.go
    ~auth_required:true
    ~rtype:POST
    ~path:["achievement_statuses"]
    ~post:post
    from_json

(* ************************************************************************** *)
(* Edit an achievement status                                                 *)
(* ************************************************************************** *)

let edit ?(status = None) ?(message = "") id =
  let post_parameters = Network.option_filter [
    ("status", Option.map Status.to_string status);
    ("message", Some message);
  ] in
  let post = Network.PostList post_parameters in
  Api.go
    ~rtype:PATCH
    ~path:(["achievement_statuses"; id_to_string id])
    ~auth_required:true
    ~post:post
    from_json

(* ************************************************************************** *)
(* Delete an achievement status                                               *)
(* ************************************************************************** *)

let delete id =
  Api.go
    ~auth_required:true
    ~rtype:DELETE
    ~path:["achievement_statuses"; id_to_string id]
    Api.noop

(* ************************************************************************** *)
(* Medias                                                                     *)
(* ************************************************************************** *)

let add_media media id =
  let post = match media with FileUrl url -> [("picture", url)] | _ -> [] in
  let post = Network.PostMultiPart
    (post, Network.files_filter [("picture", media)], ApiMedia.checker) in
  Api.go
    ~auth_required:true
    ~rtype:POST
    ~path:["achievement_statuses"; id_to_string id; "medias"]
    ~post:post
    ApiMedia.from_json

let delete_media id =
  Api.go
    ~auth_required:true
    ~rtype:DELETE
    ~path:["medias"; id_to_string id]
    Api.noop

(* ************************************************************************** *)
(* Vote                                                                       *)
(* ************************************************************************** *)

let vote = Api.vote "achievement_statuses" from_json
let cancel_vote = Api.cancel_vote "achievement_statuses" from_json

(* ************************************************************************** *)
(* Comments                                                                   *)
(* ************************************************************************** *)

let comments = ApiComment.get "achievement_statuses"
let add_comment = ApiComment.create "achievement_statuses"
let edit_comment = ApiComment.edit
let delete_comment = ApiComment.delete
let vote_comment = ApiComment.vote
let cancel_vote_comment = ApiComment.cancel_vote
