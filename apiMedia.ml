(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)

open Yojson.Basic.Util
open ApiTypes

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

(* todo check what happens if the exetions are raised *)
let extension filename =
  let start = try (String.rindex filename '.') + 1 with Not_found -> 0
  in try String.sub filename start ((String.length filename) - start)
    with Invalid_argument s -> ""

let extension_of_path path =
  try extension (List.hd (List.rev path))
  with Failure _ -> ""

let checker l contenttype = List.exists ((=) contenttype) l

let guess_contenttype_from_extension extension =
  match String.lowercase extension with
  | "jpg" | "jpeg" | "jpe" -> "image/jpeg"
  | "png" -> "image/png"
  | "bmp" -> "image/bmp"
  | "gif" -> "image/gif"
  | "mp4" | "mp4v" | "mpg4" -> "video/mp4"
  | "mpeg" | "mpg" | "mpe" | "m1v" | "m2v" -> "video/mpeg"
  | _ -> "text/plain"

let guess_contenttype filename =
  guess_contenttype_from_extension (extension filename)

let guess_contenttype_from_path path =
  guess_contenttype_from_extension (extension_of_path path)

(* ************************************************************************** *)
(* Picture                                                                    *)
(* ************************************************************************** *)

module type PICTURE =
sig
  type t =
    {
      info      : Info.t;
      url_small : url;
      url_big   : url;
    }
  val from_json : Yojson.Basic.json -> t
  val contenttypes : contenttype list
  val checker : contenttype -> bool
end

module Picture : PICTURE =
struct
  type t =
    {
      info      : Info.t;
      url_small : url;
      url_big   : url;
    }
  let from_json c =
    {
      info      = Info.from_json c;
      url_small = c |> member "url_small" |> to_string;
      url_big   = c |> member "url_big"   |> to_string;
    }
  let contenttypes = [
    "image/jpeg";
    "image/png";
    "image/bmp";
  ]
  let checker = checker contenttypes
end

(* ************************************************************************** *)
(* Video                                                                      *)
(* ************************************************************************** *)

module type VIDEO =
sig
  type t =
    {
      info      : Info.t;
      url       : url;
      thumbnail : Picture.t;
    }
  val from_json : Yojson.Basic.json -> t
  val contenttypes : contenttype list
  val checker : contenttype -> bool
end

module Video : VIDEO =
struct
  type t =
    {
      info      : Info.t;
      url       : url;
      thumbnail : Picture.t;
    }
  let from_json c =
    {
      info      = Info.from_json c;
      url       = c |> member "url" |> to_string;
      thumbnail = Picture.from_json (c |> member "thumbnail");
    }
  let contenttypes = [
    "video/mp4";
  ]
  let checker = checker contenttypes
end

module type EXTERNALVIDEO =
sig
  type provider =
    | Youtube
    | DailyMotion
    | Vimeo
    | Unknown
  type t =
    {
      info      : Info.t;
      provider  : provider;
      video_url : url;
      thumbnail : Picture.t;
    }
  val from_json : Yojson.Basic.json -> t
  val provider_to_string : provider -> string
  val provider_of_string : string -> provider
end
module ExternalVideo : EXTERNALVIDEO =
struct
  type provider =
    | Youtube
    | DailyMotion
    | Vimeo
    | Unknown
  type t =
    {
      info      : Info.t;
      provider  : provider;
      video_url : url;
      thumbnail : Picture.t;
    }
  let provider_to_string = function
    | Youtube     -> "youtube"
    | DailyMotion -> "dailymotion"
    | Vimeo       -> "vimeo"
    | Unknown     -> "unknown"
  let provider_of_string = function
    | "youtube"     -> Youtube
    | "dailymotion" -> DailyMotion
    | "vimeo"       -> Vimeo
    | _             -> Unknown
  let from_json c =
    {
      info      = Info.from_json c;
      provider  = provider_of_string (c |> member "provider" |> to_string);
      video_url = c |> member "url" |> to_string;
      thumbnail = Picture.from_json (c |> member "thumbnail");
    }
end

(* ************************************************************************** *)
(* Media                                                                      *)
(* ************************************************************************** *)

type t =
  | Picture of Picture.t
  | Video   of Video.t
  | ExternalVideo of ExternalVideo.t
  | Media   of (string * string)
  | Id      of string

let from_json c = (* todo match type with *)
  try Picture (Picture.from_json c)
  with
    | Yojson.Basic.Util.Type_error (msg, tree) -> Id (c |> to_string)

let checker = checker (Picture.contenttypes @ Video.contenttypes)
