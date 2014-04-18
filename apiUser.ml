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
      info                     : Info.t;
      login                    : login;
      firstname                : string;
      lastname                 : string;
      name                     : string;
      avatar                   : ApiMedia.Picture.t option;
      gender                   : Gender.t;
      birthday                 : Date.t option;
      email                    : email option;
      (* score                    : int; *)
      (* level                    : int; *)
      following                : bool option;
      url                      : url;
    }

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

let from_json c =
  let open Yojson.Basic.Util in
  let open ApiMedia in
      {
        info        = Info.from_json c;
        login       = c |> member "login" |> to_string;
        firstname   = c |> member "firstname" |> ApiTypes.to_string_option;
        lastname    = c |> member "lastname" |> ApiTypes.to_string_option;
        name        = c |> member "name" |> ApiTypes.to_string_option;
        avatar      = c |> member "avatar" |> to_option Picture.from_json;
        gender      = Gender.of_string (c |> member "gender" |> to_string);
        birthday    = c |> member "birthday" |> to_option
            (fun d -> Date.of_string (d |> to_string));
        email       = c |> member "email" |> to_string_option;
        (* score       = c |> member "score" |> to_int; *)
        (* level       = c |> member "level" |> to_int; *)
	following   = c |> member "in_game_network" |> to_bool_option;
        url         = c |> member "url" |> to_string;
      }

let equal u1 u2 =
  u1.login = u2.login

(* ************************************************************************** *)
(* API Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get users                                                                  *)
(* ************************************************************************** *)

let get ?(term = []) ?(page = Page.default_parameters) () =
    (* ?(with_avatar = None) ?(genders = []) *)
    (* ?(lang = []) ?(min_score = None) ?(max_score = None) *)
    (* ?(min_level = None) ?(max_level = None) *)
    (* ?(is_in_network = None) () = *)
  Api.go
    ~path:["users"]
    ~page:(Some page)
    ~get:(Network.option_filter
            [("term", Some (Network.list_parameter term));
             (* ("with_avatar", Option.map string_of_bool with_avatar); *)
             (* ("genders", Some (Network.list_parameter *)
             (*                     (List.map Gender.to_string genders))); *)
             (* ("lang", Some (Network.list_parameter *)
             (*                  (List.map Lang.to_string lang))); *)
             (* ("min_score", Option.map string_of_int min_score); *)
             (* ("max_score", Option.map string_of_int max_score); *)
             (* ("min_level", Option.map string_of_int min_level); *)
             (* ("max_level", Option.map string_of_int max_level); *)
             (* ("is_in_network", Option.map string_of_bool is_in_network); *)
            ])
    (Page.from_json from_json)

(* ************************************************************************** *)
(* Get one user                                                               *)
(* ************************************************************************** *)

let get_one id =
  Api.go
    ~path:["users"; id]
    from_json

(* ************************************************************************** *)
(* Create a user                                                              *)
(* ************************************************************************** *)

let create ~login ~email ?(lang = Lang.default) ?(firstname = "") ?(lastname = "")
    ?(gender = Gender.default) ?(birthday = None) ?(avatar = NoFile) either =
  let either = match either with
    | Password password -> [("password", password)]
    | OAuth (oauth_provider, oauth_token) ->
      [("oauth_provider", oauth_provider); ("oauth_token", oauth_token)]
  in
  let post_parameters = either
    @ (Network.option_filter
	 ([("login",     Some login);
	  ("email",     Some email);
	  ("firstname", Some firstname);
	  ("lastname",  Some lastname);
	  ("gender",    Some (Gender.to_string gender));
	  ("birthday",  Option.map Date.to_string birthday);
	 ] @ (match avatar with FileUrl url -> [("avatar", Some url)] | _ -> []))
    ) in
  let post =
    Network.PostMultiPart
      (post_parameters,
       Network.files_filter [("avatar", avatar)],
       ApiMedia.Picture.checker) in
  Api.go
    ~rtype:POST
    ~path:["users"]
    ~post:post
    from_json

(* ************************************************************************** *)
(* Edit a user                                                                *)
(* ************************************************************************** *)

let edit
    ?(email = "")
    ?(password = None)
    ?(firstname = "")
    ?(lastname = "")
    ?(gender = Gender.default)
    ?(birthday = None)
    ?(avatar = NoFile)
    user =
   let post_parameters =
    Network.option_filter
      ([("email", Some email);
	("firstname", Some firstname);
	("lastname", Some lastname);
	("gender", Some (Gender.to_string gender));
	("birthday", Option.map Date.to_string birthday);
       ]
       @ (match password with
	 | None -> []
	 | Some (old_password, password) -> [
	   ("old_password", Some old_password);
	   ("password", Some password);
	 ])
       @ (match avatar with FileUrl url -> [("avatar", Some url)] | _ -> [])
      ) in
   let post =
     Network.PostMultiPart
       (post_parameters,
	Network.files_filter [("avatar", avatar)],
	ApiMedia.Picture.checker) in
   Api.go
     ~rtype:PUT
     ~path:["users"; user]
     ~auth_required:true
     ~post:post
     from_json

(* ************************************************************************** *)
(* Get followers                                                              *)
(* ************************************************************************** *)

let get_followers ?(page = Page.default_parameters) user =
  Api.go
    ~path:["users"; user; "followers"]
    ~page:(Some page)
    (Page.from_json from_json)

(* ************************************************************************** *)
(* Get following                                                              *)
(* ************************************************************************** *)

let get_following ?(page = Page.default_parameters) user =
  Api.go
    ~path:["users"; user; "following"]
    ~page:(Some page)
    (Page.from_json from_json)

(* ************************************************************************** *)
(* Follow                                                                     *)
(* ************************************************************************** *)

let follow user =
  Api.go
    ~auth_required:true
    ~rtype:POST
    ~path:["users"; user; "followers"]
    Api.noop

let unfollow user =
  Api.go
    ~auth_required:true
    ~rtype:DELETE
    ~path:["users"; user; "followers"]
    Api.noop
