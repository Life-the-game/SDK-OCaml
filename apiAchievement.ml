(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)

open ExtLib
open ApiTypes
open Network

(* ************************************************************************** *)
(* Types                                                                      *)
(* ************************************************************************** *)

type achievement_status =
    {
      id     : id;
      status : Status.t;
    }

type t =
    {
      info               : Info.t;
      vote               : Vote.t;
      owner              : ApiUser.t;
      comments           : int;
      name               : string;
      description        : string;
      mutable icon       : Picture.t option;
      color              : color option;
      tags               : string list;
      achievement_status : achievement_status option;
      location           : Location.t option;
      secret             : bool option;
      visibility         : Visibility.t;
      total_comments     : int;
      difficulty         : int;
      url                : url;
    }

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

let rec from_json c =
  let open Yojson.Basic.Util in
      {
        info               = Info.from_json c;
	vote               = Vote.from_json c;
	owner              = ApiUser.from_json (c |> member "owner");
	comments           = c |> member "comments" |> ApiTypes.to_int_option;
        name               = c |> member "name" |> to_string;
        description        = c |> member "description" |> ApiTypes.to_string_option;
        icon               = (c |> member "icon"
                                |> to_option Picture.from_json);
        color              = c |> member "color" |> to_string_option;
        tags               = ApiTypes.convert_each (c |> member "tags") to_string;
        achievement_status = c |> member "achievement_status" |> to_option
            (fun c -> {
              id     = c |> member "id" |> to_int;
              status = Status.of_string (c |> member "status" |> to_string);
             }
            );
        location           = (try (Some (Location.from_json c)) with _ -> None);
        secret             = c |> member "secret" |> to_bool_option;
        visibility         = Visibility.of_string
          (match c |> member "visibility" |> to_string_option with Some s -> s | None -> "");
	      total_comments    = c |> member "total_comments" |> ApiTypes.to_int_option;
	      difficulty        = c |> member "difficulty" |> ApiTypes.to_int_option;
        url                = c |> member "website_url" |> to_string;
      }

(* ************************************************************************** *)
(* Api Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get Achievements                                                           *)
(* ************************************************************************** *)

let get ~session ?(page = Page.default_parameters)
    ?(terms = []) ?(tags = []) ?(location = None) () =
  Api.go
    ~session:session
    ~path:["achievements"]
    ~page:(Some page)
    ~get:(Network.option_filter
            [("search", Some (Network.list_parameter terms));
             ("tags", Some (Network.list_parameter tags));
             ("location", Option.map Location.to_string location);
            ])
    (Page.from_json from_json)

(* ************************************************************************** *)
(* Get one Achievement                                                        *)
(* ************************************************************************** *)

let get_one ~session id =
  Api.go
    ~session:session
    ~path:["achievements"; id_to_string id]
    from_json

(* ************************************************************************** *)
(* Create a new Achievement                                                   *)
(* ************************************************************************** *)

let create ~session ~name ~description ?(icon = NoFile) ?(color = "")
    ?(secret = false) ?(tags = []) ?(location = None) ?(radius = 0) ?(difficulty = 1) ()  =
  let radius = if radius > 0 then string_of_int radius else ""
  and location = match location with
    | Some l -> Location.to_string l | None -> "" in
  let post_parameters =
    Network.empty_filter
      [("name", name);
       ("description", description);
       ("icon", match icon with FileUrl url -> url | _ -> "");
       ("color", color);
       ("tags", Network.list_parameter tags);
       ("difficulty", (string_of_int difficulty));
       ("secret", if secret then "1" else "0");
       ("location", location);
       ("radius", radius);
      ] in
  let post =
    Network.PostMultiPart
      (post_parameters, Network.files_filter [("icon", icon)],
       Picture.checker) in
  Api.go
    ~session:session
    ~auth_required:true
    ~rtype:POST
    ~path:["achievements"]
    ~post:post
    from_json

(* ************************************************************************** *)
(* Edit an Achievement                                                        *)
(* ************************************************************************** *)

let edit ~session ?(name = "") ?(description = "") ?(icon = NoFile) ?(color = "")
    ?(secret = None) ?(add_tags = []) ?(delete_tags = []) ?(difficulty = 1) id =
  let post_parameters =
    Network.empty_filter
      [("name", name);
       ("description", description);
       ("icon", match icon with FileUrl url -> url | _ -> "");
       ("color", color);
       ("difficulty", (string_of_int difficulty));
       ("add_tags", Network.list_parameter add_tags);
       ("delete_tags", Network.list_parameter delete_tags);
       ("secret", match secret with Some b -> string_of_bool b | None -> "");
      ] in
  let post =
    Network.PostMultiPart
      (post_parameters, Network.files_filter [("icon", icon)],
       Picture.checker) in
  Api.go
    ~session:session
    ~auth_required:true
    ~rtype:PATCH
    ~path:["achievements"; id_to_string id]
    ~post:post
    from_json

(* ************************************************************************** *)
(* Delete an Achievement                                                      *)
(* ************************************************************************** *)

let delete ~session id =
  Api.go
    ~session:session
    ~auth_required:true
    ~rtype:DELETE
    ~path:["achievements"; id_to_string id]
    Api.noop

(* ************************************************************************** *)
(* Tags                                                                       *)
(* ************************************************************************** *)

let tags ~session id =
  Api.go
    ~session:session
    ~rtype:GET
    ~path:["achievements"; id_to_string id; "tags"]
    (fun c -> ApiTypes.convert_each c Yojson.Basic.Util.to_string)

let add_tags ~session tags id =
  Api.go
    ~session:session
    ~auth_required:true
    ~rtype:POST
    ~path:["achievements"; id_to_string id; "tags"]
    ~get:[("tags", list_parameter tags)]
    from_json

let delete_tags ~session tags id =
  Api.go
    ~session:session
    ~auth_required:true
    ~rtype:DELETE
    ~path:["achievements"; id_to_string id; "tags"]
    ~get:[("tags", list_parameter tags)]
    from_json

let all_tags ~session () =
  Api.go
    ~session:session
    ~path:["tags"]
    (fun c -> ApiTypes.convert_each c
      (fun c -> let open Yojson.Basic.Util in
		(c |> member "tag" |> to_string,
		 c |> member "total_achievements" |> ApiTypes.to_int_option)))

(* ************************************************************************** *)
(* Icon                                                                       *)
(* ************************************************************************** *)

let delete_icon ~session id =
  Api.go
    ~session:session
    ~rtype:DELETE
    ~path:["achievements"; id_to_string id; "icon"]
    ~auth_required:true
    Api.noop

let icon ~session id icon =
  let go post = Api.go
    ~session:session
    ~rtype:POST
    ~path:["achievements"; id_to_string id; "icon"]
    ~auth_required:true
    ~post:post
    (fun c ->
      let open Yojson.Basic.Util in
      (c |> member "icon" |> Picture.from_json)) in
  match icon with
    | FileUrl url -> go (PostList [("icon", url)])
    | File file -> go (PostMultiPart ([], [("icon", file)],
				      Picture.checker))
    | NoFile -> Error requirement_missing

(* ************************************************************************** *)
(* Vote                                                                       *)
(* ************************************************************************** *)

let vote = Api.vote "achievements" from_json
let cancel_vote = Api.cancel_vote "achievements" from_json

(* ************************************************************************** *)
(* Comments                                                                   *)
(* ************************************************************************** *)

let comments = ApiComment.get "achievements"
let add_comment = ApiComment.create "achievements"
let edit_comment = ApiComment.edit
let delete_comment = ApiComment.delete
let vote_comment = ApiComment.vote
let cancel_vote_comment = ApiComment.cancel_vote
