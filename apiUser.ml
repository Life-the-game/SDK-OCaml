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

type t = _user

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

let from_json c =
  let open Yojson.Basic.Util in
      {
	creation    = Info.creation c;
	modification= Info.modification c;
        login       = c |> member "login" |> to_string;
        firstname   = c |> member "first_name" |> ApiTypes.to_string_option;
        lastname    = c |> member "last_name" |> ApiTypes.to_string_option;
        name        = c |> member "name" |> ApiTypes.to_string_option;
        avatar      = c |> member "avatar" |> to_option Picture.from_json;
        gender      = Gender.of_string (c |> member "gender" |> to_string);
        birthday    = c |> member "birthday" |> to_option
            (fun d -> Date.of_string (d |> to_string));
        email       = c |> member "email" |> to_string_option;
        (* score       = c |> member "score" |> to_int; *)
        (* level       = c |> member "level" |> to_int; *)
	following   = c |> member "following" |> to_bool_option;
        url         = c |> member "website_url" |> to_string;
      }

let dummy = {
	creation    = CalendarLib.Calendar.make 2013 12 01 9 5 6;
	modification= CalendarLib.Calendar.make 2013 12 01 9 5 6;
        login       = "dummy";
        firstname   = "";
        lastname    = "";
        name        = "";
        avatar      = None;
        gender      = Gender.Undefined;
        birthday    = None;
        email       = None;
	following   = None;
        url         = "";
      }

let equal u1 u2 =
  u1.login = u2.login

(* ************************************************************************** *)
(* API Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get users                                                                  *)
(* ************************************************************************** *)

let get ~session ?(term = []) ?(page = Page.default_parameters) () =
    (* ?(with_avatar = None) ?(genders = []) *)
    (* ?(lang = []) ?(min_score = None) ?(max_score = None) *)
    (* ?(min_level = None) ?(max_level = None) *)
    (* ?(is_in_network = None) () = *)
  Api.go
    ~session:session
    ~path:["players"]
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

let get_one ~session id =
  Api.go
    ~session:session
    ~path:["players"; id]
    from_json

(* ************************************************************************** *)
(* Create a user                                                              *)
(* ************************************************************************** *)

let create ~session ~login ~email ?(lang = Lang.default) ?(firstname = "") ?(lastname = "")
    ?(gender = Gender.default) ?(birthday = None) either =
  let either = match either with
    | Password password -> [("password", password)]
    | OAuth (oauth_provider, oauth_token) ->
      [("provider", oauth_provider); ("provider_access_token", oauth_token)]
  in
  let post_parameters = either
    @ (Network.option_filter [
      ("login",     Some login);
      ("email",     Some email);
      ("first_name", Some firstname);
      ("last_name",  Some lastname);
      ("gender",    Some (Gender.to_string gender));
      ("birthday",  Option.map Date.to_string birthday);
    ]) in
  let post = PostList post_parameters in
  Api.go
    ~session:session
    ~rtype:POST
    ~path:["players"]
    ~post:post
    from_json

(* ************************************************************************** *)
(* Edit a user                                                                *)
(* ************************************************************************** *)

let edit
    ~session
    ?(email = "")
    ?(password = None)
    ?(firstname = "")
    ?(lastname = "")
    ?(gender = Gender.default)
    ?(birthday = None)
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
      ) in
   let post = PostList post_parameters in
   Api.go
    ~session:session
     ~rtype:PATCH
     ~path:["players"; user]
     ~auth_required:true
     ~post:post
     from_json

(* ************************************************************************** *)
(* Avatar                                                                     *)
(* ************************************************************************** *)

let delete_avatar ~session user =
  Api.go
    ~session:session
    ~rtype:DELETE
    ~path:["players"; user; "avatar"]
    ~auth_required:true
    Api.noop

let avatar ~session user avatar =
  let go post = Api.go
    ~session:session
    ~rtype:POST
    ~path:["players"; user; "avatar"]
    ~auth_required:true
    ~post:post
    (fun c ->
      let open Yojson.Basic.Util in
	  c |> member "avatar" |> to_string) in
  match avatar with
    | FileUrl url -> go (PostList [("avatar", url)])
    | File file -> go (PostMultiPart ([], [("avatar", file)],
				      Picture.checker))
    | NoFile -> match delete_avatar ~session:session user with
	| Error e -> Error e
	| Result () -> Result ""

(* ************************************************************************** *)
(* Get followers                                                              *)
(* ************************************************************************** *)

let get_followers ~session ?(page = Page.default_parameters) user =
  Api.go
    ~session:session
    ~path:["players"; user; "followers"]
    ~page:(Some page)
    (Page.from_json from_json)

(* ************************************************************************** *)
(* Get following                                                              *)
(* ************************************************************************** *)

let get_following ~session ?(page = Page.default_parameters) user =
  Api.go
    ~session:session
    ~path:["players"; user; "following"]
    ~page:(Some page)
    (Page.from_json from_json)

(* ************************************************************************** *)
(* Follow                                                                     *)
(* ************************************************************************** *)

let follow ~session user =
  Api.go
    ~session:session
    ~auth_required:true
    ~rtype:POST
    ~path:["players"; user; "followers"]
    Api.noop

let unfollow ~session user =
  Api.go
    ~session:session
    ~auth_required:true
    ~rtype:DELETE
    ~path:["players"; user; "followers"]
    Api.noop

(* ************************************************************************** *)
(* Challenge                                                                  *)
(* ************************************************************************** *)

let challenge ~session user achievement =
  Api.go
    ~session:session
    ~auth_required:true
    ~rtype:POST
    ~path:["players"; user; "challenge"]
    ~post:(PostList [
      ("achievement", achievement);
    ])
    Api.noop

(* ************************************************************************** *)
(* Send a message                                                             *)
(* ************************************************************************** *)

let message ~session user message =
  Api.go
    ~session:session
    ~auth_required:true
    ~rtype:POST
    ~path:["players"; user; "challenge"]
    ~post:(PostList [
      ("message", message);
    ])
    Api.noop

