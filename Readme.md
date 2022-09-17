# ECE-564 Vapor Server

## **Models**


* ### **UserAuth:**

    This is how the UserAuth Model is defined in the code. The UserAuth entries have a unique constraint on the username field.
    ```
    enum UserType{
        case Professor
        case TA        # TA = Teaching Assistant
        case Student
    }



    final class UserAuth: Model, Content{
        var id: UUID?
        var username: String
        var password: String?
        var userType: UserType
    }

    ```
* ### **DukePersonEntry**:

    ```
    final class DukePersonEntry: Model, Content{
        var id: String?
        var netid: String
        var firstname: String
        var lastname: String
        var wherefrom: String
        var gender: String
        var role: String
        var degree: String
        var team: String
        var hobbies: [String]
        var languages: [String]
        var department: String
        var email: String
        var picture: String     
    }
    ```
## **Routes**:
All the following routes require a basicAuthorization HTTP header, where a valid username and password entry is required. 
***
+ `GET` /user/all:

    Returns a list of UserAuth entries, `[UserAuth]`.
    This entry allows an authorized TA/Professor to access entries depending on the following rules:

    * Professors have access to all entries
    * TAs can access all students' entries along with their own
    * Students don't have access to this route
***
+ `POST` /user/create:

    Since it is a route based on the POST HTTP Method, it requires JSON data conforming to the model as shown above. An example JSON query would be: 
    ```
        {
            "username": "IAmATestUser",
            "password": "Yayy",
            "userType": "TA"
        }
    ```
    or you could just skip the password field and query something like:
    ```
        {
            "username": "AnotherTestUser",
            "userType": "Professor" 
        }
    ```
    In this case, the password will be generated by the code. 
    This route allows a Professor/TA to create new UserAuth entries. This route follows these rules: 
    * Professors can create/update any and all entries.
    * TAs can only create new students' entries.
    * Students don't have access to this route
***
+ `PATCH` /user:

    This route is used to update UserAuth password and their UserType. Since it is the `PATCH` method, it requires JSON data in the request. Matching is done based on the username. Following rules are obeyed: 
    * Professors can update any entry irrespective of the user's role
    * TAs can only update their own details, or other students' details
    * Students don't have access to this route
***
+ `DELETE` /user/<u>username</u>:

    This route is used to delete any entry from the database. The <u>username</u> part is replaced by the actual user's username. So if a Professor/TA wanted to delete a user's entry whos username was <u>IAmATestUser</u>, they would enter the following URL: 
    `http://ece564server-vapor.colab.duke.edu/user/IAmATestUser`.

***

+ `GET` /entries/:

    This route is the route where all students' information can be seen. 

***

+ `POST` /entries/create:

    This route allows a new DukePersonEntry to be created and saved in the database. The `Content-Type` Header in the request should be `application/json` and also requires `Basic Authorization` details in the request. 
    A basic JSON query would look like: 
    ``` 
        {
            "firstname": "John",
            "lastname": "Doe", 
            "netid": "jd122222223",
            "wherefrom": "Earth",
            "gender": "Male",
            "role": "Student",
            "degree": "MS",
            "team": "Duke",
            "hobbies": ["writing", "code"],
            "languages": ["C++", "Swift"],
            "department": "ECE",
            "email": "jjj@jjj.edu",
            "picture": "here is where the base 64 encoded string would go"
        }
    ```
    The username and password should be a valid entry in the UserAuth Table. Content creation follows these norms:
    
    * The username provided in the basicAuthorization header should be same as the username in the json content. So that a person is only able to modify their entry.

***

+ `GET` /entries/all:

    This route returns a `[DukePersonEntry]`, so that all the entries can be accessed by anyone. Once again, basic Authorization headers are required and the user should be existing the UserAuth table. 

***

+ `DELETE` /entries/<u>id</u>:

    This route is used to delete entries from the DukePersonEntry Table. <u>id</u>  is the ID associated with the DukePersonEntry. As usual, credentials are required and a person can only delete their entry. 