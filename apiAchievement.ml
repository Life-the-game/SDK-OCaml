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
      comments           : int;
      name               : string;
      description        : string option;
      icon               : ApiMedia.Picture.t option;
      color              : color option;
      tags               : string list;
      achievement_status : achievement_status option;
      location           : Location.t option;
      secret             : bool option;
      visibility         : Visibility.t;
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
	comments           = c |> member "comments" |> ApiTypes.to_int_option;
        name               = c |> member "name" |> to_string;
        description        = c |> member "description" |> to_string_option;
        icon              = (c |> member "icon"
                                |> to_option ApiMedia.Picture.from_json);
        color              = c |> member "color" |> to_string_option;
        tags               = ApiTypes.convert_each (c |> member "tags") to_string;
        achievement_status = None;(* c |> member "achievement_status" |> to_option *)
            (* (fun c -> { *)
            (*   id     = c |> member "id" |> to_int; *)
            (*   status = Status.of_string (c |> member "status" |> to_string); *)
            (*  } *)
            (* ); *)
        location           = (try (Some (Location.from_json c)) with _ -> None);
        secret             = c |> member "secret" |> to_bool_option;
        visibility         = Visibility.of_string
          (match c |> member "visibility" |> to_string_option with Some s -> s | None -> "");
        url                = c |> member "url" |> to_string;
      }

(* ************************************************************************** *)
(* Api Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get Achievements                                                           *)
(* ************************************************************************** *)

let get ?(page = Page.default_parameters)
    ?(terms = []) ?(tags = []) ?(location = None) () =
  Api.go
    ~path:["achievements"]
    ~page:(Some page)
    ~get:(Network.option_filter
            [("terms", Some (Network.list_parameter terms));
             ("tags", Some (Network.list_parameter tags));
             ("location", Option.map Location.to_string location);
            ])
    (Page.from_json from_json)

(* ************************************************************************** *)
(* Get one Achievement                                                        *)
(* ************************************************************************** *)

let get_one id =
  Api.go
    ~path:["achievements"; id_to_string id]
    from_json

(* ************************************************************************** *)
(* Create a new Achievement                                                   *)
(* ************************************************************************** *)

let create ~name ~description ?(icon = NoFile) ?(color = "")
    ?(secret = false) ?(tags = []) ?(location = None) ?(radius = 0) () =
  let radius = if radius > 0 then string_of_int radius else ""
  and location = match location with
    | Some l -> Location.to_string l | None -> "" in
  let post_parameters =
    Network.empty_filter
      [("name", name);
       ("description", description);
       ("icon", match icon with FileUrl url -> url | _ -> "");
       ("color", color);
       ("secret", if secret then "1" else "0");
       ("tags", Network.list_parameter tags);
       ("location", location);
       ("radius", radius);
      ] in
  let post =
    Network.PostMultiPart
      (post_parameters, Network.files_filter [("icon", icon)],
      ApiMedia.Picture.checker) in
  Api.go
    ~auth_required:true
    ~rtype:POST
    ~path:["achievements"]
    ~post:post
    from_json

(* ************************************************************************** *)
(* Edit an Achievement                                                        *)
(* ************************************************************************** *)

let edit ?(name = "") ?(description = "") ?(icon = NoFile) ?(color = "")
    ?(secret = None) ?(add_tags = []) ?(del_tags = []) id =
  let post_parameters =
    Network.empty_filter
      [("name", name);
       ("description", description);
       ("icon", match icon with FileUrl url -> url | _ -> "");
       ("color", color);
       ("secret", match secret with Some b -> string_of_bool b | None -> "");
       ("add_tags", Network.list_parameter add_tags);
       ("del_tags", Network.list_parameter del_tags);
      ] in
  let post =
    Network.PostMultiPart
      (post_parameters, Network.files_filter [("icon", icon)],
       ApiMedia.Picture.checker) in
  Api.go
    ~auth_required:true
    ~rtype:PUT
    ~path:["achievements"; id_to_string id]
    ~post:post
    from_json

(* PRIVATE *)

(* ************************************************************************** *)
(* Delete an Achievement                                                      *)
(* ************************************************************************** *)

let delete id =
  Api.go
    ~auth_required:true
    ~rtype:DELETE
    ~path:["achievements"; id_to_string id]
    Api.noop

(* /PRIVATE *)

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
