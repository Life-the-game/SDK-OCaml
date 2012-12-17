(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools to get/edit users                                       *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

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

(* Return information about a user using its login/id.                        *)
(* Authentification required.                                                 *)
val get_user         : ApiAuth.auth -> string -> (user, Api.errors) Api.result
val get_user_from_id : ApiAuth.auth -> int    -> (user, Api.errors) Api.result

(* Take: login firstname surname gender birthdate email password              *)
(* Return information about the user created.                                 *)
val create_user :
  string -> string -> string -> ApiTypes.Gender.t
  -> ApiTypes.Date.t -> string -> string
  -> (user, Api.errors) Api.result
