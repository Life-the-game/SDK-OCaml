(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools to get/edit users                                       *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

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

val get_user : string -> user

