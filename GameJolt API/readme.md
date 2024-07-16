###### GameJolt API Ndll for CodenameEngine © 2024 by Neo & ItsLJcool is licensed under CC BY-NC-SA 4.0. To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/4.0/

## Welcome to Neo & LJ's NDLL GameJolt API!
This api is updated to v1.2 as of now.

Here you can learn how to call functions and to initalize your NDLL calls.

If you are copying this NDLL, please credit Me (ItsLJcool) and Neo with these links:  <br/>
ItsLJcool:<br/>
https://www.youtube.com/@ItsLJcool | Discord: @ItsLJcool<br/>
Neo: https://x.com/Ne_Eo_Twitch | Discord: @ne_eo<br/>

Lets get started with the documentation!

# GameJolt NDLL API
First off, before explaining I am going to show you how to format your custom API shit.<br/>
I do this to all my API stuff (Like my [LJ Arcade API](../LJ%20Arcade%20API) scripts) so im going to force you to do the same. Though please credit me for giving you this knowledge because it so easy. 🙏

## Formatting API
First, make a new Folder inside your CNE mod, example: `LJ Arcade > GameJolt API`<br/>
You would do `your mod > GameJolt API` (you can name the folder whatever tho)<br/>
We are making it a folder instead of outside chilling because formatting.

Now we can add our `.hx` script. It can be named anything but probably `API.hx`.


We will be importing this script using CodenameEngine's `importScript` function. Meaning all the functions we make will need to be `public function` or `public var` to make it accessable in the actual script we are importing from.<br/>
If we just name a variable without `public` it will be internal to that script.

Lets make a Init function, like:
```haxe
import funkin.backend.utils.NdllUtil; // I don't think this import will change but if so make sure you check source to be sure.
import Type; // since CNE doesn't auto import Type

var ndllName = "gamejolt-api"; // our GameJolt NDLL name
public function gamejolt_init() {
    // we get the function for init and then call it immediately with a Typedef param (since for some reason NDLL's cant reflect the class type itself)
    // Arguments for getFunction is (name:String, function_name:String, args:Int)
    NdllUtil.getFunction(ndllName, "gamejolt_init", 2)(Type,
    "AES Encryption here");
}
```
### How to get the AES Encryption Key
You can get the AES Encryption Key by using the following code:
```haxe
NdllUtil.getFunction(ndllName, "gamejolt_init", 2)("GameJolt's Game Private Key", "game_id"); // 2nd param for game_id can be an int or a string
```
Now make sure you call the `_init` function in your `data > global.hx` like so:
```haxe
// this will run when the script is first initalized, so on script create I guess.
function new() {
    gamejolt_init(); // call the public function
}
```
And we are done with initalizing the NDLL!!

# Ndll API Functions
This section is to document all the functions you can call with the Ndll.<br/>
Code examples will have the `result` variable as the return value of the function, so you can just copy and trace the result to see what it returns.<br/>
## Users/
### Auth - GameJolt API Endpoint: `(users/auth)`

This function is used to authenticate the user with GameJolt, and returns a `response` object with a `success` value of `true` or `false`.

#### Parameters
- > `username` **[ string ]** - The username of the user you are trying to authenticate.
- >`token` **[ string ]** - The token of the user you are trying to authenticate.

#### Example
```haxe
var result = NdllUtil.getFunction(ndllName, "gamejolt_login", 2)( "GameJolt Username", "GameJolt Token" );
```

### Fetch - GameJolt API Endpoint: `(users)`
This function is used to fetch the user's information from GameJolt, and returns a `response` object with a `success` value of `true` or `false`.<br/>
It also returns a `user` object with the user's information.<br/>
See the [GameJolt API Docs](https://gamejolt.com/api/doc/game/users/fetch) to get the data structure of the `user` object.

#### Parameters
> [!NOTE]
> Username and User ID are the same thing, but I'm using them interchangeably. So its a one parameter function, so you can only use one of the two parameters.

> - `username` **[ string ]** - The username of the user you are trying to fetch.
> - `user_id` **[ int ]** - The user id of the user you are trying to fetch.

#### Example
```haxe
var result = NdllUtil.getFunction(ndllName, "gamejolt_fetch", 1)( "GameJolt Username / ID" );
```

## Sessions/
### Create - GameJolt API Endpoint: `(sessions/create)`
This function is used to create a session with GameJolt, and returns a `response` object with a `success` value of `true` or `false`.

#### Parameters
- `None`

#### Example
```haxe
var result = NdllUtil.getFunction(ndllName, "openSession_0", 0)();
```