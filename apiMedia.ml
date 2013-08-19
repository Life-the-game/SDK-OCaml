(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Medias (pictures, sounds, videos) stuff                       *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/SDK-OCaml   *)
(* ************************************************************************** *)

open Yojson.Basic.Util
open ApiTypes

(* ************************************************************************** *)
(* Picture                                                                    *)
(* ************************************************************************** *)

module type PICTURE =
sig
  type t =
    {
      url_small : url;
      url_big   : url;
    }
  val from_json : Yojson.Basic.json -> t
  val path_to_contenttype : path -> contenttype option
end

module Picture : PICTURE =
struct
  type t =
    {
      url_small : url;
      url_big   : url;
    }
  let from_json c =
    {
      url_small = c |> member "url_small" |> to_string;
      url_big   = c |> member "url_big"   |> to_string;
    }
  let path_to_contenttype path =
    match List.hd (List.rev path) with (* todo get ext *)
    | "jpg" -> Some ""
    | "png" -> Some ""
    | "bmp" -> Some ""
    | _     -> None
end

(* ************************************************************************** *)
(* Video                                                                      *)
(* ************************************************************************** *)

module type VIDEO =
sig
  type t =
    {
      url       : url;
      thumbnail : Picture.t;
    }
  val from_json : Yojson.Basic.json -> t
  val path_to_contenttype : path -> contenttype option
end

module Video : VIDEO =
struct
  type t =
    {
      url       : url;
      thumbnail : Picture.t;
    }
  let from_json c =
    {
      url       = c |> member "url" |> to_string;
      thumbnail = Picture.from_json (c |> member "thumbnail");
    }
  let path_to_contenttype path =
    match List.hd (List.rev path) with (* todo get ext *)
    | "mp4" -> Some ""
    | _     -> None
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
      provider = provider_of_string (c |> member "provider" |> to_string);
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

let from_json c =
  match c |> member "type" |> to_string with
    | "picture" -> Picture (Picture.from_json c)
    | "video"   -> Video (Video.from_json c)
    | "external_video" -> ExternalVideo (ExternalVideo.from_json c)
    | other     -> Media (other, c |> to_string)

let path_to_contenttype path =
  match Picture.path_to_contenttype path with
    | Some c -> Some c
    | None ->
      match Video.path_to_contenttype path with
	| Some c -> Some c
	| None -> None
