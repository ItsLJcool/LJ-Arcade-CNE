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
var aesKey = NdllUtil.getFunction(ndllName, "gamejolt_init", 2)("GameJolt's Game Private Key", "game_id"); // 2nd param for game_id can be an int or a string

trace(aesKey); // your AES Encryption
```
Now make sure you call the `_init` function in your `data > global.hx` like so:
```haxe
importScript("GameJolt API/API"); // import the script
// this will run when the script is first initalized, so on script create I guess.
function new() {
    gamejolt_init(); // call the public function
}
```
And to make it so API calls that use the `username` and `token` variables will work, we need to call the `gamejolt_login` in the _init function as well, or make your own custom login function.
```haxe
NdllUtil.getFunction(ndllName, "gamejolt_login", 2)( "GameJolt Username", "GameJolt Token" );
```
And we are done with initalizing the NDLL!!

# Ndll API Functions

> [!WARNING]
> Not all of these functions have been thouroughly tested, so please make sure to test them before using them in your mod.<br/>
If you please report any bugs, please make sure to include the function name and the parameters you used.<br/><br/>
And DM Me or Neo on Discord if you need any help with the functions.

This section is to document all the functions you can call with the Ndll.<br/>
Code examples will have the `result` variable as the return value of the function, so you can just copy and trace the result to see what it returns.<br/>
## Users/
### Auth - GameJolt API Endpoint: `(users/auth)`

This function is used to authenticate the user with GameJolt, and returns a `response` object with a `success` value of `true` or `false`.

#### Parameters
> - `username` **[ string ]** - The username of the user you are trying to authenticate.
> - `token` **[ string ]** - The token of the user you are trying to authenticate.

This will also set the internal `user` and `token` variables to the username and token.

#### Example
```haxe
NdllUtil.getFunction(ndllName, "gamejolt_login", 2)( "GameJolt Username", "GameJolt Token" );
```

### Fetch - GameJolt API Endpoint: `(users)`
This function is used to fetch the user's information from GameJolt, and returns a `response` object with a `success` value of `true` or `false`.<br/>
It also returns a `user` object with the user's information.<br/>
See the [GameJolt API Docs](https://gamejolt.com/api/doc/game/users/fetch) to get the data structure of the `user` object.

#### Parameters
> - `username` **[ string ]** - The username of the user you are trying to fetch.
> - `user_id` **[ int ]** - The user id of the user you are trying to fetch.

> [!NOTE]
> Username and User ID are the same thing, but I'm using them interchangeably. So its a one parameter function, so you can only use one of the two parameters.

#### Example
```haxe
NdllUtil.getFunction(ndllName, "gamejolt_fetch", 1)( "GameJolt Username / ID" );
```

## Sessions/
### Open - GameJolt API Endpoint: `(sessions/open)`
This function is used to create a session with GameJolt, and returns a `response` object with a `success` value of `true` or `false`.

#### Parameters
> - `None`

#### Example
```haxe
NdllUtil.getFunction(ndllName, "openSession_0", 0)();
```

### Ping - GameJolt API Endpoint: `(sessions/ping)`
This function is used to ping a session with GameJolt, and returns a `response` object with a `success` value of `true` or `false`.

#### Parameters
> - `status` **[ string ]** - The status of the session you are trying to ping.

> [!NOTE]
> This parameter is optional, without a parameter it just returns if it successfully pinged the session.<br/>
> The status can be `active` or `idle`.

#### Example
```haxe
NdllUtil.getFunction(ndllName, "pingSession_0", 0)();

NdllUtil.getFunction(ndllName, "pingSession_1", 1)("active");
```

### Check - GameJolt API Endpoint: `(sessions/check)`
This function is used to check if a session is open with GameJolt, and returns a `response` object with a `success` value of `true` or `false`.

#### Parameters
> - `None`

#### Example
```haxe
NdllUtil.getFunction(ndllName, "checkSession_0", 0)();
```

### Close - GameJolt API Endpoint: `(sessions/close)`
This function is used to close a session with GameJolt, and returns a `response` object with a `success` value of `true` or `false`.

#### Parameters
> - `None`

#### Example
```haxe
NdllUtil.getFunction(ndllName, "closeSession_0", 0)();
```

## Scores/
### Fetch - GameJolt API Endpoint: `(scores/fetch)`
This function is used to fetch the scores of a user from GameJolt, and returns a `response` object with a `success` value of `true` or `false`.

#### Parameters
> - `user` **[ boolean ]** - To use the user's data or not.
> - `limit` **[ int ]** - The number of scores you'd like to return.
> - `table_id` **[ int ]** - The table id of the scores you'd like to fetch.
> - `guest` **[ string ]** - The guest of the scores you'd like to fetch.

<br/>

> - `better_than` **[ int ]** - The score you'd like to fetch scores better than a value.
> - `worse_than` **[ int ]** - The score you'd like to fetch scores worse than a value.

<br/>

> [!WARNING]
> The `user` parameter is NOT optional, it is required to be `true` or `false`.<br/>
If `user` `false`, then you **must** provide the `guest` parameter.<br/>
if `user` is `true`, then the guest field is nullified.

> [!NOTE]
> The reason why `better_than` and `worse_than` are seperate is because the GameJolt API doesn't support the `better_than` and `worse_than` parameters at the same time, so you have to use the correct function.<br/>

#### Example
```haxe
NdllUtil.getFunction(ndllName, "fetchScores_3", 3)(true, 10, 1);

NdllUtil.getFunction(ndllName, "fetchScores_4", 4)(true, 10, 1, "doesnt matter");

NdllUtil.getFunction(ndllName, "fetchScores_4", 4)(false, 10, 1, "Guest_Name");

NdllUtil.getFunction(ndllName, "fetchScores_better_5", 5)(false, 10, 1, "Guest_Name", 100);

NdllUtil.getFunction(ndllName, "fetchScores_worse_5", 5)(false, 10, 1, "Guest_Name", 100);
```

### Tables - GameJolt API Endpoint: `(scores/tables)`
This function is used to fetch the tables of a user from GameJolt, and returns a `response` object with a `success` value of `true` or `false`.

#### Parameters
> - `None`

#### Example
```haxe
NdllUtil.getFunction(ndllName, "fetchTables_0", 0)();
```

### UpdateScore - GameJolt API Endpoint: `(scores/add)`
This function is used to update a score of a user from GameJolt, and returns a `response` object with a `success` value of `true` or `false`.

#### Parameters
> - `user` **[ boolean ]** - To use the user's data or not.
> - `score` **[ string ]** - The score you'd like to name. Example: `500 Points`.
> - `sort` **[ int ]** - The actual score you'd like to add. Example: `500`.
> - `guest` **[ string ]** - The guest of the scores you'd like to add the score to.
> - `table_id` **[ int ]** - The table id of the scores you'd like to add the score to.
> - `extra_data` **[ string ]** - Extra data to add to the score. Acts like a custom variable.

> [!NOTE]
> The `user` parameter is NOT optional, it is required to be `true` or `false`.<br/>
If `user` `false`, then you **must** provide the `guest` parameter.<br/>
if `user` is `true`, then the guest field is nullified.<br/><br/>


> [!WARNING]
> The `extra_data` and `table_id` parameter are optional, its a bit confusing<br/><br/>
If you are using **5** parameters, if you are using the `table_id` variable, then its just `updateScore_5`<br/><br/>
Otherwiseif you are using the `extra_data` variable, then its just `updateScore_extra_6`<br/><br/>
When you are using **6** parameters, you must use the `table_id` and `extra_data` parameters **in that order.**<br/>

#### Example
```haxe
NdllUtil.getFunction(ndllName, "updateScore_5", 5)(true, "500 Points", 500, "Doesnt matter", table_id);

NdllUtil.getFunction(ndllName, "updateScore_extra_5", 5)(true, "500 Points", 500, "Doesnt matter", "Exra Data");

NdllUtil.getFunction(ndllName, "updateScore_6", 6)(true, "500 Points", 500, "Doesnt matter", table_id, "Extra Data");

NdllUtil.getFunction(ndllName, "updateScore_6", 6)(false, "500 Points", 500, "Guest_Name", table_id, "Extra Data");
```

### Get Rank - GameJolt API Endpoint: `(scores/get-rank)`
This function is used to get the rank of a score from GameJolt, and returns a `response` object with a `success` value of `true` or `false`.

#### Parameters
> - `sort` **[ int ]** - The actual score you'd like to get the rank of.
> - `table_id` **[ int ]** - The table id of the scores you'd like to get the rank of. **(Optional)**

#### Example
```haxe
NdllUtil.getFunction(ndllName, "getRank_2", 2)(500, table_id);
```

## Trophies/
### Fetch - GameJolt API Endpoint: `(trophies)`
This function is used to fetch the trophies of a user from GameJolt, and returns a `response` object with a `success` value of `true` or `false`.

#### Parameters
> - `achieved` **[ boolean ]** - To get user has achieved the trophies. **(Optional)**
> - `trophy_id` **[ int ]** - The trophy id of the trophy you'd like to fetch. **(Optional)**

#### Example
```haxe
NdllUtil.getFunction(ndllName, "fetchTrophies_0", 0)();

NdllUtil.getFunction(ndllName, "fetchTrophies_1", 1)(true);

NdllUtil.getFunction(ndllName, "fetchTrophies_2", 2)(false, trophy_id);
```

### Unlock - GameJolt API Endpoint: `(trophies/add-achieved)`
This function is used to unlock a trophy of a user from GameJolt, and returns a `response` object with a `success` value of `true` or `false`.

#### Parameters
> - `trophy_id` **[ int ]** - The trophy id of the trophy you'd like to unlock.

#### Example
```haxe
NdllUtil.getFunction(ndllName, "unlockTrophy_1", 1)(trophy_id);
```

### Remove - GameJolt API Endpoint: `(trophies/remove-achieved)`
This function is used to remove a trophy of a user from GameJolt, and returns a `response` object with a `success` value of `true` or `false`.

#### Parameters
> - `trophy_id` **[ int ]** - The trophy id of the trophy you'd like to remove.

#### Example
```haxe
NdllUtil.getFunction(ndllName, "removeTrophy_1", 1)(trophy_id);
```

## Data-Store/
### Set - GameJolt API Endpoint: `(data-store/set)`
This function is used to set the data-store of a user from GameJolt, and returns a `response` object with a `success` value of `true` or `false`.

#### Parameters
> - `user` **[ boolean ]** - To use the user's data or not.
> - `key` **[ string ]** - The key of the data you'd like to set.
> - `value` **[ string ]** - The value of the data you'd like to set.

#### Example
```haxe
// user stored data
NdllUtil.getFunction(ndllName, "storeData_3", 3)(true, "key", "value");

// public data
NdllUtil.getFunction(ndllName, "storeData_3", 3)(false, "key", "value");
```
### Fetch - GameJolt API Endpoint: `(data-store)`
This function is used to fetch the data-store of a user from GameJolt, and returns a `response` object with a `success` value of `true` or `false`.

#### Parameters
> - `user` **[ boolean ]** - To use the user's data or not.
> - `key` **[ string ]** - The key of the data you'd like to fetch.

#### Example
```haxe
// user stored data
NdllUtil.getFunction(ndllName, "fetchData_2", 2)(true, "key");

// public data
NdllUtil.getFunction(ndllName, "fetchData_2", 2)(false, "key");
```

### Remove - GameJolt API Endpoint: `(data-store/remove)`
This function is used to remove the data-store of a user from GameJolt, and returns a `response` object with a `success` value of `true` or `false`.

#### Parameters
> - `user` **[ boolean ]** - To use the user's data or not.
> - `key` **[ string ]** - The key of the data you'd like to remove.

#### Example
```haxe
// user stored data
NdllUtil.getFunction(ndllName, "removeData_2", 2)(true, "key");

// public data
NdllUtil.getFunction(ndllName, "removeData_2", 2)(false, "key");
```

### Update - GameJolt API Endpoint: `(data-store/update)`
This function is dumb, dont use it lmao.

#### Parameters
> - `user` **[ boolean ]** - To use the user's data or not.
> - `operation` **[ string ]** - The operation you'd like to perform on the data. (See GameJolt API Docs too lazy to say it here)
> - `value` **[ string ]** - uh lazy again go look up the GameJolt API Docs.

#### Example
```haxe
// user stored data
NdllUtil.getFunction(ndllName, "updateData_3", 3)(true, operation, value);

// public data
NdllUtil.getFunction(ndllName, "updateData_3", 3)(false, operation, value);
```

### Get-Keys - GameJolt API Endpoint: `(data-store/get-keys)`
This function is used to get the keys of the data-store of a user from GameJolt, and returns a `response` object with a `success` value of `true` or `false`.

#### Parameters
> - `user` **[ boolean ]** - To use the user's data or not.
> - `pattern` **[ string ]** - The pattern of the keys you'd like to get. **(Optional)** | Check GameJolt API Docs for more info.
#### Example
```haxe
// user stored data
NdllUtil.getFunction(ndllName, "getKeys_1", 1)(true);

// public data
NdllUtil.getFunction(ndllName, "getKeys_1", 1)(false);

NdllUtil.getFunction(ndllName, "getKeys_2", 2)(false, pattern);
```

## Friends/
### Freinds - GameJolt API Endpoint: `(friends)`
This function is used to fetch the friends of a user from GameJolt, and returns a `response` object with a `success` value of `true` or `false`.

#### Parameters
> - `None`

#### Example
```haxe
NdllUtil.getFunction(ndllName, "getUserFriends_0", 0)();
```

## Time/
### Server Time - GameJolt API Endpoint: `(time)`
This function is used to get the server time from GameJolt, and returns a `response` object with a `success` value of `true` or `false`.

#### Parameters
> - `None`

#### Example
```haxe
NdllUtil.getFunction(ndllName, "getServerTime_0", 0)();
```

# Thats all the documentation for the GameJolt API!
There are some issues I want to address.

### 1. Authentication function
The `gamejolt_login` auto sets the `username` and `token` variables inside the NDLL. This means that if you use the `gamejolt_login` function to authenticate another user, the `username` and `token` variables will be overwritten. I plan on fixing this in the future. with a function but im lazy right now.
### 2. Asyncronous functions
Doesn't exist, nor work because of how Scripting works in CNE.

Neo and I are aware of this and will plan on seeing if we can add it in the future, though it might break the API since we might refactor the calling of functions.

