(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools to get/edit achievements                                *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

open Api.RequestType
open ApiTypes
open ExtLib

(* ************************************************************************** *)
(* Types                                                                      *)
(* ************************************************************************** *)

type t =
    {
      info               : Info.t;
      login              : login;
      firstname          : string;
      lastname           : string;
      avatar             : ApiMedia.Picture.t;
      gender             : Gender.t;
      birthday           : Date.t;
      is_friend          : bool option;
      profile_url        : url;
    }

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

(* Take a json tree representing a user and return an object user             *)
let from_json c =
  let open Yojson.Basic.Util in
      {
	info        = Info.from_json c;
	login       = c |> member "login" |> to_string;
	firstname   = c |> member "firstname" |> to_string;
	lastname    = c |> member "lastname" |> to_string;
	avatar      = ApiMedia.Picture.from_json (c |> member "avatar");
	gender      = Gender.of_string (c |> member "gender" |> to_string);
	birthday    = Date.of_string (c |> member "birthday" |> to_string);
	is_friend   = c |> member "is_friend" |> to_bool_option;
	profile_url = c |> member "profile_url" |> to_string;
      }

(* ************************************************************************** *)
(* Api Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Create a user                                                              *)
(* ************************************************************************** *)

let create ~login ~email ~password ~lang ?(firstname = None) ?(lastname = None)
    ?(gender = None) ?(birthday = None) () =
  let url = Api.url ~parents:["users"] ~lang:(Some lang)
    ~get:(Api.option_filter
	    [("login", Some login);
	     ("email", Some email);
	     ("password", Some password);
	     ("firstname", firstname);
	     ("lastname", lastname);
	     ("gender", Option.map Gender.to_string gender);
	     ("birthday", Option.map Date.to_string birthday);
	    ]) () in
  Api.go ~rtype:POST url from_json

(* ************************************************************************** *)
(* Get users                                                                  *)
(* ************************************************************************** *)

let get ~auth ?(term = None) ?(index = None) ?(limit = None) () =
  let url = Api.url ~parents:["users"] ~auth:(Some auth)
    ~get:(Api.option_filter
	    [("term", term);
	     ("index", Option.map string_of_int index);
	     ("limit", Option.map string_of_int limit)]) () in
  Api.go ~auth:(Some auth) url (ApiTypes.List.from_json from_json)

(* ************************************************************************** *)
(* Get a user                                                                 *)
(* ************************************************************************** *)

let get_user ?(auth = None) ?(lang = None) id =
  let url = Api.url ~parents:["users"; id] ~auth:auth ~lang:lang () in
  Api.any ~auth:auth ~lang:lang url from_json

(* ************************************************************************** *)
(* Delete a user                                                              *)
(* ************************************************************************** *)

let delete ~auth id =
  let url = Api.url ~parents:["users"; id] ~auth:(Some auth) () in
  Api.noop ~auth:(Some auth) ~rtype:DELETE url

(* ************************************************************************** *)
(* Edit (put) a user                                                          *)
(* ************************************************************************** *)

let edit ~auth ?(email = None) ?(password = None) ?(firstname = None)
    ?(lastname = None) ?(gender = None) ?(birthday = None) id =
  let url = Api.url ~parents:["users"; id] ~auth:(Some auth)
    ~get:(Api.option_filter
	    [("email", email);
	     ("password", password);
	     ("firstname", firstname);
	     ("lastname", lastname);
	     ("gender", Option.map Gender.to_string gender);
	     ("birthday", Option.map Date.to_string birthday);
	    ]) () in
  Api.go ~auth:(Some auth) ~rtype:PUT url from_json

(* ************************************************************************** *)
(* Get user's authentication tokens                                           *)
(* ************************************************************************** *)

let get_tokens ~auth ?(index = None) ?(limit = None) user_id =
  let url = Api.url ~parents:["users"; user_id; "tokens"] ~auth:(Some auth)
    ~get:(Api.option_filter
	    [("index", Option.map string_of_int index);
	     ("limit", Option.map string_of_int limit)]) () in
  Api.go ~auth:(Some auth) url (ApiTypes.List.from_json ApiAuth.from_json)

(* ************************************************************************** *)
(* Get user's friends                                                         *)
(* ************************************************************************** *)

let get_friends ?(auth = None) ?(lang = None)
    ?(index = None) ?(limit = None) user_id =
  let url = Api.url ~parents:["users"; user_id; "friends"] ~auth:auth ~lang:lang
    ~get:(Api.option_filter
	    [("index", Option.map string_of_int index);
	     ("limit", Option.map string_of_int limit)]) () in
  Api.any ~auth:auth ~lang:lang url (ApiTypes.List.from_json from_json)
