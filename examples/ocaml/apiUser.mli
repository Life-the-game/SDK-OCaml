(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools to get/edit users                                       *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
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

val get_user : string -> user

val create_user :
  string -> string -> string -> ApiTypes.Gender.t
  -> ApiTypes.Date.t -> string -> string -> unit
