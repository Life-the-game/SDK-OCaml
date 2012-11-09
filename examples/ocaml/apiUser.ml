(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools to get/edit users                                       *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

open Yojson.Basic.Util

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

let get_user login =
  let tree = Api.curljson (ApiConf.base_url ^ "user/" ^ login) in
  {
    id                = tree |> member "id" |> to_int;
    creation_time     =
      ApiTypes.DateTime.of_string (tree |> member "creation_time" |> to_string);
    modification_time =
      ApiTypes.DateTime.of_string (tree |> member "modification_time"
				      |> to_string);
    login             = tree |> member "login" |> to_string;
    firstname         = tree |> member "firstname" |> to_string;
    surname           = tree |> member "surname" |> to_string;
    gender            =
      ApiTypes.Gender.of_string (tree |> member "gender" |> to_string);
    birthdate         =
      ApiTypes.Date.of_string (tree |> member "birthdate" |> to_string);
    email             = tree |> member "email" |> to_string;
  }

let create_user login firstname surname gender birthdate email password =
  let result =
    Api.curljson
      (ApiConf.base_url
       ^ "user/register/"
       ^ "?login=" ^ login
       ^ "&firstname=" ^ firstname
       ^ "&surname=" ^ surname
       ^ "&gender=" ^ (ApiTypes.Gender.to_string gender)
       ^ "&birthdate=" ^ (ApiTypes.Date.to_string birthdate)
       ^ "&email=" ^ email
       ^ "&password=" ^ password
      ) in
  match result with
    | `String s -> print_endline s
    | `Assoc l -> print_endline ((snd (List.hd l)) |> to_string)
    | _ -> print_endline "unknown"
