(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** API Special Types                                                         *)

(* ************************************************************************** *)
(** {3 Summary}                                                               *)
(** {ol
    {- Explicit types for parameters }
    {- Files }
    {- Network stuff (GET POST ...) }
    {- Languages }
    {- Requirements (Auth, Lang, ...) }
    {- Date & Time }
    {- Information Element }
    {- Vote elements }
    {- List Pagination }
    {- Status }
    {- Gender }
    {- Location }
    {- Visibility }
    {- Error }
    {- Client-side errors }
    {- API Response }
    }                                                                         *)
(* ************************************************************************** *)

val convert_each :
  Yojson.Basic.json
  -> (Yojson.Basic.json -> 'a)
  -> 'a list

val to_int_option : Yojson.Basic.json -> int
val to_string_option : Yojson.Basic.json -> string

(* ************************************************************************** *)
(** {3 Explicit types for parameters}                                         *)
(* ************************************************************************** *)

type id       = int
val id_to_string : id -> string
val id_of_string : string -> id

type login    = string
type password = string
type email    = string
type url      = string
type token    = string
type color    = string
type mimetype = string

type oauth_provider = string
type oauth_token    = token

type either =
  | Password of password
  | OAuth of (oauth_provider * oauth_token)

type parameters = (string (* key *) * string (* value *)) list

(* ************************************************************************** *)
(** {3 Files}                                                                 *)
(* ************************************************************************** *)

type filename = string
type contenttype = string
type path = string list
type file = (path * contenttype)
type either_file =
  | FileUrl of url
  | File of file
  | NoFile
type file_parameter = (filename * file)

val path_to_string : path -> string

(* ************************************************************************** *)
(** {3 Network stuff (GET POST ...)}                                          *)
(* ************************************************************************** *)

module type NETWORK =
sig
  type t =
    | GET
    | POST
    | PUT
    | PATCH
    | DELETE
  type post =
    | PostText of string
    | PostList of parameters
    | PostMultiPart of parameters * file_parameter list * (contenttype -> bool)
    | PostEmpty
  type code = int
  val default   : t
  val to_string : t -> string
  val of_string : string -> t
(** Clean an option list by removing all the "None" and empty elements.
    Note that the order of the list will be reversed. *)
  val option_filter  : (string * string option) list -> parameters
  val empty_filter   :  parameters -> parameters
  val files_filter   : (filename * either_file) list -> file_parameter list
  val multiple_files_filter : string -> either_file list -> file_parameter list
  val multiple_files_url_filter : string -> either_file list -> parameters
  val list_parameter : string list -> string
end
module Network : NETWORK

(* ************************************************************************** *)
(** {3 Languages}                                                             *)
(* ************************************************************************** *)

module type LANG =
sig
  type t
  val list        : string list
  val default     : t
  val is_valid    : string -> bool
  val of_string : string -> t
  val to_string   : t      -> string
end
module Lang : LANG

(* ************************************************************************** *)
(** {3 Date & Time}                                                           *)
(* ************************************************************************** *)

(** Full time with date + hour                                                *)
module type DATETIME =
sig
  type t = CalendarLib.Calendar.t
  val format : string

  val to_string : t -> string
  val to_simple_string : t -> string
  val of_string : string -> t

  val empty : t
  val now : unit -> t
  val is_past : t -> bool
end
module DateTime : DATETIME

(** Only date                                                                 *)
module type DATE =
sig
  type t = CalendarLib.Date.t
  val format : string

  val to_string : t -> string
  val of_string : string -> t

  val empty : t
  val today : unit -> t
end
module Date : DATE


(* ************************************************************************** *)
(** {3 Information Element}                                                   *)
(**  Almost all API object contains this object                               *)
(* ************************************************************************** *)

module type INFO =
sig
  type t =
      {
        id           : id;
        creation     : DateTime.t;
        modification : DateTime.t;
      }
  val from_json : Yojson.Basic.json -> t
  val creation : Yojson.Basic.json -> DateTime.t
  val modification : Yojson.Basic.json -> DateTime.t
end
module Info : INFO

(* ************************************************************************** *)
(** {3 Vote elements}                                                         *)
(**   Vote elements contain this object AND MUST contain Info as well         *)
(* ************************************************************************** *)

module type VOTE =
sig
  type vote = Up | Down
  type t =
      {
	downvotes : int;
	upvotes   : int;
	score     : int;
	vote      : vote option;
      }
  val from_json : Yojson.Basic.json -> t
  val to_string : vote -> string
  val of_string : string -> vote
end
module Vote : VOTE

(* ************************************************************************** *)
(** {3 List Pagination}                                                       *)
(* ************************************************************************** *)

module type PAGE =
sig
  type order = string
  type size = int
  type number = int
  type 'a t =
      {
	total       : size;
	size        : size;
	number      : number;
	next        : number option;
	previous    : number option;
        items       : 'a list;
      }
  type parameters = (number * size option * order option)
  val default_parameters : parameters
  (** Take a page and return the arguments to get the next one,
      or None if there's no next page *)
  val next : ?order:string -> 'a t -> parameters option
  val previous : ?order:string -> 'a t -> parameters option
  (** Generate a page from the JSON tree using a converter function *)
  val from_json :
    (Yojson.Basic.json -> 'a)
    -> Yojson.Basic.json
    -> 'a t
  val just_limit : size -> parameters
  val get_total: 'a t -> size
end
module Page : PAGE

(* ************************************************************************** *)
(** {3 Gender}                                                                *)
(* ************************************************************************** *)

module type GENDER =
sig
  type t = Male | Female | Other | Undefined
  val default   : t
  val to_string : t -> string
  val of_string : string -> t
end
module Gender : GENDER

(* ************************************************************************** *)
(** {3 Status}                                                                *)
(* ************************************************************************** *)

module type STATUS =
sig
  type t =
    | Objective
    | Unlocked
  val to_string : t -> string
  val of_string : string -> t
end
module Status : STATUS

(* ************************************************************************** *)
(** {3 Colors}                                                                *)
(* ************************************************************************** *)

val colors : (string * string) list
val main_colors : (string * string) list
val light_colors : (string * string) list
val name_to_color : string -> string

(* ************************************************************************** *)
(** {3 Location}                                                              *)
(* ************************************************************************** *)

module type LOCATION =
sig
  type t = {
    latitude: float;
    longitude: float;
    radius: int;
  }
  type parameters = (float * float)
  val to_string : parameters -> string
  val of_string : ?radius : int -> string -> t
  val from_json : Yojson.Basic.json -> t
end
module Location : LOCATION

(* ************************************************************************** *)
(** {3 Visibility}                                                            *)
(* ************************************************************************** *)

module type VISIBILITY =
sig
  type t =
    | Official
    | Community
    | Sponsored
    | Unknown
  val default : t
  val to_string : t -> string
  val of_string : string -> t
end
module Visibility : VISIBILITY

(* ************************************************************************** *)
(** {3 Error}                                                                 *)
(* ************************************************************************** *)

type error =
  | BadRequest of string
  | NotFound of string
  | NotAllowed of string
  | NotAcceptable of string
  | InternalServerError of string
  | NotImplemented of string
  | Client of string
  | Unknown of (Network.code * string)

val error_from_json : Network.code -> string -> error

(* ************************************************************************** *)
(** {3 Client-side errors}                                                    *)
(* ************************************************************************** *)

val generic             : error
val network             : string -> error
val invalid_json        : string -> error
val requirement_missing : error
val invalid_format      : error
val file_not_found      : error
val invalid_argument    : string -> error
val auth_required       : error
val notfound            : error

(* ************************************************************************** *)
(** {3 Multi Media Tools}                                                     *)
(* ************************************************************************** *)

val extension : string -> string
val extension_of_path : path -> string
val checker : contenttype -> bool

val guess_contenttype : string -> contenttype
val guess_contenttype_from_extension : string -> contenttype
val guess_contenttype_from_path : path -> contenttype

(* ************************************************************************** *)
(** {3 Picture}                                                               *)
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
module Picture : PICTURE

(* ************************************************************************** *)
(** {3 Video}                                                                 *)
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
module Video : VIDEO

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
module ExternalVideo : EXTERNALVIDEO

(* ************************************************************************** *)
(** {3 Media}                                                                 *)
(* ************************************************************************** *)

type media =
  | Picture of Picture.t
  | Video   of Video.t
  | ExternalVideo of ExternalVideo.t
  | Media   of (string * string)
  | Id      of string

val media_from_json : Yojson.Basic.json -> media
val media_thumbnail : media -> url
val media_url       : media -> url
val media_id        : media -> id

(* ************************************************************************** *)
(* Session Types Dependency                                                   *)
(* ************************************************************************** *)

type _auth =
    {
      access_token  : token;
      token_type    : string;
      expires_in    : int;
      refresh_token : token;
      scope         : string list;
    }

type _user =
    {
      creation                 : DateTime.t;
      modification             : DateTime.t;
      login                    : login;
      firstname                : string;
      lastname                 : string;
      name                     : string;
      avatar                   : Picture.t option;
      gender                   : Gender.t;
      birthday                 : Date.t option;
      email                    : email option;
      (* score                    : int; *)
      (* level                    : int; *)
      following                : bool option;
      url                      : url;
    }

(* ************************************************************************** *)
(* Session                                                                    *)
(* ************************************************************************** *)

type session = {
  mutable auth : (_auth * _user) option;
  mutable lang : Lang.t;
  mutable connection : Curl.t option;
}

(* ************************************************************************** *)
(** {3 API Response}                                                          *)
(* ************************************************************************** *)
type 'a t =
  | Result of 'a
  | Error of error

exception OtherError of error
