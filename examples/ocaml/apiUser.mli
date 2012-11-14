(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools to get/edit users                                       *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

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

val get_user         : string -> user result
val get_user_from_id : int    -> user result

(* Take: login firstname surname gender birthdate email password              *)
(* Return a string option corresponding to the status of the request:         *)
(* - Some string if an error occured, the string is the error message         *)
(* - None if the request is successful                                        *)
val create_user :
  string -> string -> string -> ApiTypes.Gender.t
  -> ApiTypes.Date.t -> string -> string -> string option
