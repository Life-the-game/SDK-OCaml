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

let generic =
  {
    message = "Something went wrong";
    stype   = "CLIENT_Error";
    code    = -1;
  }

let network msg =
  {
    message = msg;
    stype   = "CLIENT_NetworkError";
    code    = -45;
  }

let invalid_json msg =
  {
    message = "The JSON tree response is not formatted as expected: " ^ msg;
    stype   = "CLIENT_InvalidJSON";
    code    = -18;
  }

let requirement_missing =
  {
    message = "One requirement is missing";
    stype   = "CLIENT_RequirementMissing";
    code    = -25;
  }
