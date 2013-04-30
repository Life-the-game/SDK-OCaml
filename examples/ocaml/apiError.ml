(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Responses Codes                                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Type                                                                       *)
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

let success =
  {
    message = "Success";
    stype   = "Success";
    code    = 0;
  }

(* ************************************************************************** *)
(* Client-side errors                                                         *)
(* ************************************************************************** *)

let invalid_json =
  {
    message = "The JSON tree response is not formatted as expected.";
    stype   = "CLIENT_InvalidJSON";
    code    = -18;
  }

let requirement_missing =
  {
    message = "One requirement is missing";
    stype   = "CLIENT_RequirementMissing";
    code    = -25;
  }
