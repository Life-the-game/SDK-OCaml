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
      name               : string;
      description        : string option;
      badge              : ApiMedia.Picture.t option;
      color              : color option;
      category           : bool;
      secret             : bool;
      discoverable       : bool;
      (* keywords           : string list; *)(*42*)
      achievement_status : achievement_status option;
      url                : url;
    }

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

let rec from_json c =
  let open Yojson.Basic.Util in
      {
        info               = Info.from_json c;
        name               = c |> member "name" |> to_string;
        description        = c |> member "description" |> to_string_option;
        badge              = (c |> member "badge"
                                |> to_option ApiMedia.Picture.from_json);
	color              = c |> member "color" |> to_string_option;
        category           = c |> member "category" |> to_bool;
        secret             = c |> member "secret" |> to_bool;
        discoverable       = c |> member "discoverable" |> to_bool;
        (* keywords           = convert_each to_string (c |> member "keywords"); *)
	achievement_status = c |> member "achievement_status" |> to_option
	    (fun c -> {
	      id     = c |> member "id" |> to_string;
	      status = Status.of_string (c |> member "status" |> to_string);
	     }
	    );
        url                = c |> member "url" |> to_string;
      }

(* ************************************************************************** *)
(* Api Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get Achievements                                                           *)
(* ************************************************************************** *)

let get ~req ?(page = Page.default_parameters)
    ?(term = []) ?(with_badge = None) ?(is_category = None)
    ?(is_secret = None) ?(is_discoverable = None) () =
  Api.go
    ~path:["achievements"]
    ~req:(Some req)
    ~page:(Some page)
    ~get:(Network.option_filter
            [("term", Some (Network.list_parameter term));
             ("with_badge", Option.map string_of_bool with_badge);
             ("is_category", Option.map string_of_bool is_category);
             ("is_secret", Option.map string_of_bool is_secret);
             ("is_discoverable", Option.map string_of_bool is_discoverable);
            ])
    (Page.from_json from_json)

(* ************************************************************************** *)
(* Get one Achievement                                                        *)
(* ************************************************************************** *)

let get_one ~req id =
  Api.go
    ~path:["achievements"; id]
    ~req:(Some req)
    from_json

(* PRIVATE *)

(* ************************************************************************** *)
(* Create a new Achievement                                                   *)
(* ************************************************************************** *)

let create ~auth ~name ~description ?(color = "") ?(parents = []) ?(badge = [])
    ?(category = false) ?(secret = false) ?(discoverable = true)
    ?(keywords = []) () =
  let post_parameters =
    Network.empty_filter
      [("name", name);
       ("description", description);
       ("parents", Network.list_parameter parents);
       ("category", string_of_bool category);
       ("secret", string_of_bool secret);
       ("discoverable", string_of_bool discoverable);
       ("color", color);
       ("keywords", Network.list_parameter keywords);
      ] in
  let post =
    Network.PostMultiPart
      (post_parameters, Network.files_filter [("badge", badge)],
      ApiMedia.Picture.path_to_contenttype) in
  Api.go
    ~rtype:POST
    ~path:["achievements"]
    ~req:(Some (Auth auth))
    ~post:post
    from_json

(* /PRIVATE *)

