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
      creation_time     : DateTime.t;
      modification_time : DateTime.t;
      login             : string;
      firstname         : string;
      surname           : string;
      gender            : string;
      birthdate         : DateTime.date;
      email             : string;
    }

let get_user login =
  let tree = Api.curljson (ApiConf.base_url ^ "user/" ^ login) in
  {
    id                = tree |> member "id" |> to_int;
    creation_time     =
      DateTime.of_string (tree |> member "creation_time" |> to_string);
    modification_time =
      DateTime.of_string (tree |> member "modification_time" |> to_string);
    login             = tree |> member "login" |> to_string;
    firstname         = tree |> member "firstname" |> to_string;
    surname           = tree |> member "surname" |> to_string;
    gender            = tree |> member "gender" |> to_string;
    birthdate         =
      DateTime.date_of_string (tree |> member "birthdate" |> to_string);
    email             = tree |> member "email" |> to_string;
  }

