{
  "id": "Application",
  "generate": {
    "generateComponent": false,
    "generateBloc": true,
    "generateRepository": true,
    "generateModel": true,
    "generateEntity": true,
  },
  "fields": [
    {
      "fieldName": "id",
      "fieldType": "String"
    },
    {
      "fieldName": "title",
      "fieldType": "String"
    },
    {
      "fieldName": "description",
      "fieldType": "String"
    },
    {
      "fieldName": "entryPageId",
      "fieldType": "String"
    },
    {
      "fieldName": "authenticationRequirement",
      "fieldType": "enum",
      "enumName": "AuthenticationRequirement",
      "enumValues" : [ "LoginRequired", "LoginOptional", "NoLogin" ]
    },
    {
      "fieldName": "logo",
      "fieldType": "Image",
      "association": true
    }
  ]
}