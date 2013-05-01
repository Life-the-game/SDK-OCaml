(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools to get/edit achievements                                *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

open Api.RequestType
open ApiTypes

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
	avatar      = c |> member "avatar" |> ApiMedia.Picture.from_json;
	gender      = Gender.of_string (c |> member "gender" |> to_string);
	birthday    = Date.of_string (c |> member "birthday" |> to_string);
	is_friend   =
	  (try (Some (c |> member "is_friend" |> to_bool))
	   with _ -> None);
	profile_url = c |> member "profile_url" |> to_string;
      }

(* ************************************************************************** *)
(* Api Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Create a user                                                              *)
(* ************************************************************************** *)

let create ~login ~email ~lang ?(firstname = "") ?(lastname = "")
    ?(gender = Gender.default) ?(birthday = Date.empty) () = (* todo: avatar *)
  let url = Api.url ~parents:["users"] ~lang:lang
    ~get:[("login", login);
	  ("email", email);
	  ("firstname", firstname);
	  ("lastname", lastname);
	  ("gender", Gender.to_string gender);
	  ("birthday", Date.to_string birthday);
	 ] () in
  Api.go ~rtype:POST url from_json
