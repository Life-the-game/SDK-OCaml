(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Type                                                                       *)
(* ************************************************************************** *)

type detail =
    {
      dcode : int;
      dtype : string;
      dmessage : string;
      key : string;
      value : string;
    }

type t =
    {
      message : string;
      stype   : string;
      code    : int;
      details : detail list;
    }

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

let _convert_each c name f =
  let open Yojson.Basic.Util in
  match c |> member name |> to_option (convert_each f) with
    | Some l -> l
    | None -> []

let detail_from_json c =
  let open Yojson.Basic.Util in
  {
    dcode = c |> member "code" |> to_int;
    dtype = c |> member "type" |> to_string;
    dmessage = c |> member "message" |> to_string;
    key = c |> member "key" |> to_string;
    value = c |> member "value" |> to_string;
  }

let from_json c =
  let open Yojson.Basic.Util in
      {
        message = c |> member "message" |> to_string;
        stype   = c |> member "type"    |> to_string;
        code    = c |> member "code"    |> to_int;
	details = _convert_each c "details" detail_from_json;
      }

(* ************************************************************************** *)
(* Client-side errors                                                         *)
(* ************************************************************************** *)

let generic =
  {
    message = "Something went wrong";
    stype   = "CLIENT_Error";
    code    = -1;
    details = [];
  }

let network msg =
  {
    message = msg;
    stype   = "CLIENT_NetworkError";
    code    = -2;
    details = [];
  }

let invalid_json msg =
  {
    message = "The JSON tree response is not formatted as expected: " ^ msg;
    stype   = "CLIENT_InvalidJSON";
    code    = -3;
    details = [];
  }

let requirement_missing =
  {
    message = "One requirement is missing";
    stype   = "CLIENT_RequirementMissing";
    code    = -4;
    details = [];
  }

let invalid_format =
  {
    message = "Invalid file format";
    stype   = "CLIENT_InvalidFileFormat";
    code    = -5;
    details = [];
  }

let invalid_argument msg =
  {
    message = msg;
    stype   = "CLIENT_InvalidArgument";
    code    = -6;
    details = [];
  }

let auth_required =
  {
    message = "Authentication required";
    stype   = "CLIENT_AuthenticationRequired";
    code    = -7;
    details = [];
  }

let notfound =
  {
    message = "Not found";
    stype   = "NotFound";
    code    = 1011;
    details = [];
  }
