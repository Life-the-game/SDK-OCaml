(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Responses Codes                                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/SDK-OCaml   *)
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
(* Tools                                                                      *)
(* ************************************************************************** *)

let from_json error_json =
  let open Yojson.Basic.Util in
      {
	message = error_json |> member "message" |> to_string;
	stype   = error_json |> member "type"    |> to_string;
	code    = error_json |> member "code"    |> to_int;
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

let invalid_argument msg =
  {
    message = msg;
    stype   = "CLIENT_InvalidArgument";
    code    = -4;
  }
