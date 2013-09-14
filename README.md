OCaml API Library
=================

This library is the implementation on client-side of the API using [OCaml programming language](http://ocaml.org/).

It is a complete library that allows you to integrate our API in any of your OCaml program.

## API Documentation

The full documentation of the API with the list of objects and methods:
* [API full documentation](http://doc.life.tl/api/OCaml/v2/).

## Install it

#### Requirements

* OCaml
* Lib OCaml: Extlib
* Lib OCaml: Curl
* Lib OCaml: Calendar
* Lib OCaml: Yojson [Yojson](http://mjambon.com/yojson.html)
 * + Yojson dependencies: [easy-format, biniou, cppo, yojson](http://mjambon.com/releases)

#### Compile

* Type `make` to compile the library.
* Type `make example` to compile the unit tests.
* To compile the libraby with your project: `ocamlfind ocamlc api.cma yourfile.ml -linkpkg`

## User corner

Since the API is not released to the public and not stable yet, it is useless to integrate this library into your project for now.

However, you can feed your curiosity with the following sample of code, or skim through the `example.ml` file. It will show you how to use the library.

You can also generate the documentation using `make doc`, or browse it [here](http://doc.life.tl/api/OCaml/v2/).

If you're interested in our project, you can follow the news
[on our website](http://eip.epitech.eu/2014/lavieestunjeu/).

#### Sample

```ocaml
match ApiUser.get_one "Arthur42" with
  | Error error -> ApiDump.error error
  | Result user -> print_endline
    ("Arthur42's gender is a " ^
        match user.ApiUser.gender with
          | Gender.Male   -> "guy"
          | Gender.Female -> "girl"
          | _             -> "weirdo")
```

## Developer corner

You should read the API full documentation (linked above) before reading this one.

It is highly recommended to read either the [generated documentation](http://doc.life.tl/api/OCaml/v2/) or the comments in the source code to understand how this library works.

#### API Methods

Each part of the API has its own module.
For instance, the API methods that handle User requests are in the `ApiUser` module (`apiUser.ml` and `apiUser.mli`).

These modules usually contains:
* the type(s) of the object(s)
* the function to convert a JSON tree into the object
* the API methods

#### API Types

We use a bunch of custom types for all our methods in the API, available in the [`ApiTypes` module](http://doc.life.tl/api/OCaml/v2/ApiTypes.html).

#### How to create an API method function?

The [`Api` module](http://doc.life.tl/api/OCaml/v2/Api.html) contains the [`go` function](http://life.db0.fr/api/OCaml/v2/Api.html#VALgo) that pretty much handles everything for you to call an API method and return its result (generate the URL, execute the method, parse the result, unwrap the elements, ...).

###### The (optional) `rtype` parameter

This is the type of the HTTP request.
Refer to the [`Network` module](http://doc.life.tl/api/OCaml/v2/ApiTypes.NETWORK.html) for its type and a bunch of useful functions.

Default: `GET`

###### The (optional) `path`

This is the path in the URL corresponding to the API method.

For instance:
```ocaml
... ~path:["a"; "b"; "c"] ...
```
will call the API method:
```
http://api.example.com/a/b/c/
```

Default: empty list

###### The (optional) `req` parameter

This one might be a little tricky.

* If it's a `None`, then it means there's no requirements
* If it's a `Some`, then its type is defined [here](http://doc.life.tl/api/OCaml/v2/ApiTypes.html#TYPErequirements)
* The `go` caller (API method function) should take as a parameter either:
a [`req`](http://doc.life.tl/api/OCaml/v2/ApiTypes.html#TYPErequirements),
an [`auth`](http://doc.life.tl/api/OCaml/v2/ApiTypes.html#TYPEauth),
or a [`Lang.t`](http://doc.life.tl/api/OCaml/v2/ApiTypes.LANG.html),
depending on what the API method required. It should never take an optional `req`,
since its the caller's job to inforce the requirements.
* To easily transform an `auth` parameter of the caller into
a `requirement` parameter of the `go` function, you can use the
[`opt_auth` function](http://doc.life.tl/api/OCaml/v2/ApiTypes.html#VALopt_auth)

Default: `None`

###### The (optional) `page` parameter

* It's a `Some` if the API method returns a [`Page`](http://doc.life.tl/api/OCaml/v2/ApiTypes.PAGE.html)
* Refer to the [`Page` module](http://doc.life.tl/api/OCaml/v2/ApiTypes.PAGE.html) for its type and a bunch of useful functions.

Default: `None`

###### The (optional) `get` parameter

* These are the GET parameters of the HTTP request.
* The type is defined [here](http://doc.life.tl/api/OCaml/v2/ApiTypes.NETWORK.html#TYPEparameters).
* When the content of a parameter is a list, you can use the `list_parameter` function to transform a list of string into a string
* When some of the caller (API method function) parameters are optional, you can use the `option_filter` to clean your list. Also check out `ExtLib.Option.map` if you need to convert some optional parameters to string.

Default: empty list

###### The (optional) `post` parameter

* It's the POST data sent within the body of the HTTP request.
* Its type is defined [here](http://doc.life.tl/api/OCaml/v2/ApiTypes.NETWORK.html#TYPEpost)

Default: `PostEmpty`

###### The _required_ function parameter

* This function will be called to transform the JSON tree into the OCaml object you want for your request.
* When the method doesn't return anything, you can give the `noop` function as the function parameter to `go`.
* When the object is a `Page`, you may use `(Page.from_json from_json)`

###### The return value

The API methods return an Api.t (defined in the [`ApiTypes` module](http://doc.life.tl/api/OCaml/v2/ApiTypes.html)).
which can contain the content you asked or an error object (defined in the [`ApiError` module](http://doc.life.tl/api/OCaml/v2/ApiError.html)).

Some errors can also occur on client-side. To keep it simple, we use the same error system as the server-side errors.
The list of available client-side errors is in the [`ApiError` module](http://doc.life.tl/api/OCaml/v2/ApiError.html).

#### The private API

The same code is used for the public and private library.

The code that handles private API parts must be between tags:
```ocaml
(* PRIVATE *)
let mycode = here
(* /PRIVATE *)
```

#### Examples of code?

The best way to understand how to add or edit API methods is to read the current available API modules :)

## Copyright/License


     Copyright 2013 Barbara Lepage

     Licensed under the Apache License, Version 2.0 (the "License");
     you may not use this file except in compliance with the License.
     You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

     Unless required by applicable law or agreed to in writing, software
     distributed under the License is distributed on an "AS IS" BASIS,
     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
     See the License for the specific language governing permissions and
     limitations under the License.
     
#### Latest version

Latest version of this project is on GitHub:
* https://github.com/Life-the-game/SDK-OCaml 
