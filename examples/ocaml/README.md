OCaml API example
=================

This is the example of usage of our API using the [OCaml programming language](http://ocaml.org/).

It aims to be a complete library that allows you to integrate our API in any of your OCaml program.

## API Documentation

The full documentation of the API with the list of objects and methods:
* [API full documentation](https://docs.google.com/document/d/1BFGTGKr5dBJFh493ZLRxjlM6Sbpfz8auVcPWWDQQISU/pub).

## User corner

Since the API is not released to the public and not stable for now, it is not possible to integrate
this library into your project yet.

If you're interested in our project, you can follow the news
[on our website](http://eip.epitech.eu/2014/lavieestunjeu/).

## Developer corner

* You should read the API full documentation (linked above) before reading this one.
* This short documentation tells you briefly the content of the files.
* The full description of the functions are directely in the source code.

###### API Methods

Each part of the API has its own module.
For instance, the API methods that handle User requests are in the `ApiUser` module (`apiUser.ml` and `apiUser.mli`).

###### API Types

We use a bunch of custom types for all our methods in the API, available in the [`ApiTypes` module](https://github.com/LaVieEstUnJeu/Public-API/blob/master/examples/ocaml/apiTypes.mli).

###### Errors handling

The API methods return an Api.t (defined in the [`ApiTypes` module](https://github.com/LaVieEstUnJeu/Public-API/blob/master/examples/ocaml/apiTypes.mli)).
which can contain the content you asked or an error object (defined in the [`ApiError` module](https://github.com/LaVieEstUnJeu/Public-API/blob/master/examples/ocaml/apiError.mli)).

Some errors can also occur on client-side. To keep it simple, we use the same error system as the server-side errors.
The list of available client-side errors is in the [`ApiError` module](https://github.com/LaVieEstUnJeu/Public-API/blob/master/examples/ocaml/apiErrors.mli).

###### Network and JSON tools

The [`Api` module](https://github.com/LaVieEstUnJeu/Public-API/blob/master/examples/ocaml/api.mli)
contains a bunch of useful functions that you can use to handle an API method.

* The `url` function helps you generate URL that correspond to the API methods.
* The `go` function pretty much handles everything for you (execute the method, parse the result, unwrap the elements, ...). It takes a converting function as a parameter.

###### Requirements

Some methods require authentication or a language.
To handle it, just add a parameter to the function of type [`auth` or `requirements` or `Lang.t`](https://github.com/LaVieEstUnJeu/Public-API/blob/master/examples/ocaml/apiTypes.mli) and give them
to the `go` function and the `url` function.

### Example of implementation of an API method

* __Requirements:__ Auth or Lang
* __URI:__ GET /strawberries/{strawberry_id}
* __Parameters:__ optional "message" of type string
* __Response:__ A Strawberry

```ocaml
(* ************************************************************************** *)
(* The strawberry container                                                   *)
(* ************************************************************************** *)

type t =
    {
      info   : ApiTypes.Info.t;
      name   : string;
      color  : string;
      expire : ApiTypes.DateTime.t;
    }

(* ************************************************************************** *)
(* A function that will convert a JSON tree to a strawberry                   *)
(* ************************************************************************** *)

let from_json content =
  let open Yojson.Basic.Util in
      {
        info   = ApiTypes.Info.from_json content;
        name   = content |> member "name"  |> to_string;
        color  = content |> member "color" |> to_string;
        expire = ApiTypes.DateTime.of_string
          (content |> member "expire" |> to_string);
      }

(* ************************************************************************** *)
(* The API method to get the strawberry                                       *)
(* ************************************************************************** *)

let get ?(auth = None) ?(lang = None) ?(message = None) strawberry_id =

  match (auth, lang) with
    (* Check if at least one requirement is provided *)
    | (None, None) -> ApiTypes.Error ApiError.requirement_missing
    | _            ->

      (* Generate the URL *)
      let url =
        (Api.url ~auth:auth ~lang:lang (* Provide the auth and language! *)
           ~parents:["strawberries"; (string_of_int strawberry_id)]
           ~get:(match message with (* This parameter is optional *)
             | Some m -> [("message", m)]
             | None   -> [])
           ()) in

      Api.go ~auth:auth url from_json
```

This function's signature would be:
```ocaml
val get :
  ?auth:(ApiTypes.auth option)
  -> ?lang:(ApiTypes.Lang.t option)
  -> ?message:(string option)
  -> int
  -> t Api.t
  ```
