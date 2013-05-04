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

(* Take a json tree representing an achievement and return anachievement      *)
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
