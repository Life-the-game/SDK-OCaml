(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Responses Codes                                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

type t =
    {
      message : string;
      stype   : string;
      code    : int;
    }


(* ************************************************************************** *)
(* Success                                                                    *)
(* ************************************************************************** *)

let success : t = 
  {
    message = "Success";
    stype   = "Success";
    code    = 0;
  }

 
