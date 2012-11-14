(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools to get/edit users                                       *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

open Yojson.Basic.Util
open Api

(* ************************************************************************** *)
(* Type User                                                                  *)
(* ************************************************************************** *)

type user =
    {
      id                : int;
      creation_time     : ApiTypes.DateTime.t;
      modification_time : ApiTypes.DateTime.t;
      login             : string;
      firstname         : string;
      surname           : string;
      gender            : ApiTypes.Gender.t;
      birthdate         : ApiTypes.Date.t;
      email             : string;
    }

(* ************************************************************************** *)
(* Api Methods                                                                *)
(* ************************************************************************** *)

(* string -> user result                                                      *)
let get_user login =
  let tree = curljson (ApiConf.base_url ^ "user/" ^ login) in
  match check_error tree with
    | Some e -> Failure e
    | None   ->
      let creation_time =
	ApiTypes.DateTime.of_string
	  (tree |> member "creation_time" |> to_string)
      and modification_time =
	  ApiTypes.DateTime.of_string
	    (tree |> member "modification_time"	|> to_string)
      and gender =
	ApiTypes.Gender.of_string (tree |> member "gender" |> to_string)
      and birthdate =
	  ApiTypes.Date.of_string (tree |> member "birthdate" |> to_string) in
      Success {
	id                = tree |> member "id" |> to_int;
	creation_time     = creation_time;
	modification_time = modification_time;
	login             = tree |> member "login" |> to_string;
	firstname         = tree |> member "firstname" |> to_string;
	surname           = tree |> member "surname" |> to_string;
	gender            = gender;
	birthdate         = birthdate;
	email             = tree |> member "email" |> to_string;
      }

(* int -> user result                                                         *)
let get_user_from_id id =
  get_user (string_of_int id)

(* Return a string option corresponding to the status of the request:         *)
(* - Some string if an error occured, the string is the error message         *)
(* - None if the request is successful                                        *)
let create_user login firstname surname gender birthdate email password =
  let result =
    let url = (ApiConf.base_url
	       ^ "user/register"
	       ^ "?login=" ^ login
	       ^ "&firstname=" ^ firstname
	       ^ "&surname=" ^ surname
	       ^ "&gender=" ^ (ApiTypes.Gender.to_string gender)
	       ^ "&birthdate=" ^ (ApiTypes.Date.to_string birthdate)
	       ^ "&email=" ^ email
	       ^ "&password=" ^ password) in
    curljson url in
  check_error result
