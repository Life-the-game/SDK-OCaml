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
      tags               : string list;
      achievement_status : achievement_status option;
      url                : url;
    }

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

let consumer_connection = ref []
let get_connection tags_api =
  try Consumer.Result (List.assoc tags_api !consumer_connection)
  with _ -> match Consumer.connect tags_api with
    | Consumer.Error e -> Consumer.Error e
    | Consumer.Result c ->
      (consumer_connection := ((tags_api, c)::!consumer_connection);
       Consumer.Result c)

let get_tags tags_api achievement_id =
  match get_connection tags_api with
    | Consumer.Error e -> []
    | Consumer.Result _ ->
      	match Consumer.go
	  ~resource:"categories"
	  ~id:achievement_id
	  ~get:[("api_url", !ApiConf.base_url)]
	  (Consumer.format_json_list (Yojson.Basic.Util.to_string))
	with
	  | Consumer.Error _ -> []
	  | Consumer.Result categories -> categories

let add_tags_ add_tags tags_api achievement_id =
  match get_connection tags_api with
    | Consumer.Error e -> ()
    | Consumer.Result _ ->
      List.iter (fun tag ->
	let tag = Str.global_replace (Str.regexp " ") "" tag in
	let tag = String.lowercase tag in
	let _ = Consumer.go
	  ~rtype:Consumer.POST
	  ~resource:"staffpicks"
	  ~id:tag
	  ~get:[("achievement_id", achievement_id);
		("api_url", !ApiConf.base_url)]
	  (Consumer.format_json_list (Yojson.Basic.Util.to_string)) in ())
	add_tags

let remove_tags_ remove_tags tags_api achievement_id =
  match get_connection tags_api with
    | Consumer.Error e -> ()
    | Consumer.Result _ ->
      List.iter (fun tag ->
	let _ = Consumer.go
	  ~rtype:Consumer.DELETE
	  ~resource:"staffpicks"
	  ~id:tag
	  ~get:[("achievement_id", achievement_id);
		("api_url", !ApiConf.base_url)]
	  (Consumer.format_json_list (Yojson.Basic.Util.to_string)) in ())
	remove_tags

let rec from_json ?(tags_api = "") c =
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
	tags               = if tags_api = "" then []
	  else get_tags tags_api (c |> member "id" |> to_string);
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
    ?(is_secret = None) ?(is_discoverable = None) ?(tags_api = "") () =
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
    (Page.from_json (from_json ~tags_api:tags_api))

(* ************************************************************************** *)
(* Get one Achievement                                                        *)
(* ************************************************************************** *)

let get_one ~req ?(tags_api = "") id =
  Api.go
    ~path:["achievements"; id]
    ~req:(Some req)
    (from_json ~tags_api:tags_api)

(* PRIVATE *)

(* ************************************************************************** *)
(* Create a new Achievement                                                   *)
(* ************************************************************************** *)

let create ~auth ~name ~description ?(color = "") ?(parents = [])
    ?(badge = NoFile)
    ?(category = false) ?(secret = false) ?(discoverable = true)
    ?(tags = []) ?(tags_api = "") () =
  let post_parameters =
    Network.empty_filter
      [("name", name);
       ("description", description);
       ("parents", Network.list_parameter parents);
       ("category", string_of_bool category);
       ("secret", string_of_bool secret);
       ("discoverable", string_of_bool discoverable);
       ("color", color);
      ] in
  let post =
    Network.PostMultiPart
      (post_parameters, Network.files_filter [("badge", badge)],
      ApiMedia.Picture.checker) in
  let r =
  Api.go
    ~rtype:POST
    ~path:["achievements"]
    ~req:(Some (Auth auth))
    ~post:post
    from_json
  in let _ = match r with
    | Error e -> ()
    | Result r ->
      let _ = if tags_api = "" then ()
	else add_tags_ tags tags_api r.info.Info.id in () in
     r


(* ************************************************************************** *)
(* Edit an Achievement                                                        *)
(* ************************************************************************** *)

let edit ~auth ?(name = "") ?(description = "") ?(color = "")
    ?(badge = NoFile) ?(add_tags = []) ?(remove_tags = []) ?(tags_api = "") id =
  let _ = if tags_api = "" then () else
      let _ = add_tags_ add_tags tags_api id in
      let _ = remove_tags_ remove_tags tags_api id in () in
  let post_parameters =
    Network.empty_filter
      [("name", name);
       ("description", description);
       ("color", color);
      ] in
  let post =
    Network.PostMultiPart
      (post_parameters, Network.files_filter [("badge", badge)],
       ApiMedia.Picture.checker) in
  Api.go
    ~rtype:PUT
    ~path:["achievements"; id]
    ~req:(Some (Auth auth))
    ~post:post
    from_json

(* /PRIVATE *)

